import Foundation

enum CCRPlannerService {
    static func makePlan(input: CCRPlanInput) -> CCRPlanResult {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            return invalidResult(message: DIRIOSLocalizer.string("ccr.validation.invalid_environment"))
        }

        let validation = CCRPlanValidator.validate(input, environment: environment)
        guard validation.isValid else {
            return CCRPlanResult(
                schedule: [],
                bailoutScenarios: [],
                tissueTrace: .empty,
                oxygenExposure: .unavailable(reason: .invalidInput),
                ppO2Timeline: [],
                ppN2Timeline: [],
                endTimeline: [],
                gasDensityTimeline: [],
                cnsTimeline: [],
                warnings: validation.issues.map { issue in
                    PlannerUserFacingMessage(
                        id: "ccr.issue.\(issue)",
                        title: DIRIOSLocalizer.string("ccr.warning.title"),
                        message: issue.localizedMessage,
                        correctiveHint: DIRIOSLocalizer.string("ccr.reference_estimate_only"),
                        severity: .warning
                    )
                },
                validationResult: validation,
                engineSegments: [],
                ttsMinutes: 0,
                totalRuntimeMinutes: 0,
                decoStops: [],
                depthProfilePoints: [],
                buhlmannState: .invalidInput
            )
        }

        let engine = CCRPlannerEngine.plan(input: input, environment: environment)
        let fullExposureResult = CCROxygenExposureIntegration.exposure(
            segments: engine.exposureSegments,
            diluent: input.diluent,
            environment: environment
        )
        let descentBottom = engine.exposureSegments.filter { $0.kind == .descent || $0.kind == .bottom }
        let descentBottomResult = descentBottom.isEmpty
            ? nil
            : CCROxygenExposureIntegration.exposure(
                segments: descentBottom,
                diluent: input.diluent,
                environment: environment
            )
        let oxygenExposure = CCROxygenExposureState.fromExposureResult(
            fullExposureResult,
            descentBottomResult: descentBottomResult
        )

        let bailoutScenarios = CCRBailoutScenarioCalculator.evaluateAll(input: input, environment: environment)
        let depthProfile = depthProfilePoints(from: engine.segments)

        var warnings: [PlannerUserFacingMessage] = []
        warnings.append(
            PlannerUserFacingCopy.localized(
                id: "ccr.disclaimer",
                titleKey: "ccr.safety.title",
                messageKey: "ccr.safety.disclaimer",
                hintKey: "ccr.reference_estimate_only",
                severity: .info
            )
        )
        if case .available(_, _, let descentBottomCNS?) = oxygenExposure,
           descentBottomCNS > Double(PlannerCNSDescentBottomCheckSettings.thresholdPercentDouble) {
            warnings.append(
                PlannerUserFacingCopy.localized(
                    id: "ccr.cns_descent_bottom",
                    titleKey: "planner.cns_descent_bottom.warning.title",
                    messageKey: "planner.cns_descent_bottom.warning",
                    hintKey: "planner.settings.cns_descent_bottom.reference_only",
                    severity: .warning
                )
            )
        }
        if case .unavailable(let reason) = oxygenExposure {
            warnings.append(
                PlannerUserFacingMessage(
                    id: "ccr.exposure.unavailable",
                    title: DIRIOSLocalizer.string("ccr.exposure.unavailable.title"),
                    message: DIRIOSLocalizer.string("ccr.exposure.unavailable.\(reason.rawValue)"),
                    correctiveHint: DIRIOSLocalizer.string("ccr.reference_estimate_only"),
                    severity: .warning
                )
            )
        }

        let ppO2Timeline = engine.timeline
        let ppN2Timeline = engine.timeline
        let endTimeline = engine.timeline
        let cnsTimeline = buildCNSTimeline(
            exposureSegments: engine.exposureSegments,
            diluent: input.diluent,
            environment: environment
        )

        return CCRPlanResult(
            schedule: engine.scheduleRows,
            bailoutScenarios: bailoutScenarios,
            tissueTrace: engine.tissueHistory,
            oxygenExposure: oxygenExposure,
            ppO2Timeline: ppO2Timeline,
            ppN2Timeline: ppN2Timeline,
            endTimeline: endTimeline,
            gasDensityTimeline: engine.timeline,
            cnsTimeline: cnsTimeline,
            warnings: warnings,
            validationResult: validation,
            engineSegments: engine.segments,
            ttsMinutes: engine.ttsMinutes,
            totalRuntimeMinutes: engine.totalRuntimeMinutes,
            decoStops: engine.decoStops,
            depthProfilePoints: depthProfile,
            buhlmannState: engine.modelState
        )
    }

    private static func buildCNSTimeline(
        exposureSegments: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)],
        diluent: CCRDiluent,
        environment: PlannerEnvironment
    ) -> [CCRCNSTimelineSample] {
        guard !exposureSegments.isEmpty else { return [] }
        var samples: [CCRCNSTimelineSample] = [CCRCNSTimelineSample(runtimeMinutes: 0, cnsPercent: 0)]
        var runtime = 0.0
        var accumulated: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)] = []
        for segment in exposureSegments {
            runtime += segment.minutes
            accumulated.append(segment)
            switch CCROxygenExposureIntegration.exposure(segments: accumulated, diluent: diluent, environment: environment) {
            case .success(let result):
                samples.append(CCRCNSTimelineSample(runtimeMinutes: runtime, cnsPercent: result.cnsSinglePercent))
            case .failure:
                break
            }
        }
        return samples
    }

    private static func depthProfilePoints(from segments: [BuhlmannRuntimeSegment]) -> [DepthProfilePoint] {
        guard !segments.isEmpty else { return [DepthProfilePoint(elapsedMinutes: 0, depthMeters: 0)] }
        var elapsed = 0.0
        var currentDepth = 0.0
        var points: [DepthProfilePoint] = [DepthProfilePoint(elapsedMinutes: 0, depthMeters: 0)]
        for segment in segments {
            let startDepth = currentDepth
            let endDepth = segment.depthMeters
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: startDepth))
            elapsed += segment.minutes
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: endDepth))
            currentDepth = endDepth
        }
        if points.last?.depthMeters != 0 {
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: 0))
        }
        return points
    }

    private static func invalidResult(message: String) -> CCRPlanResult {
        var validation = CCRPlanValidationResult()
        validation.issues.append(.invalidDepth(message))
        return CCRPlanResult(
            schedule: [],
            bailoutScenarios: [],
            tissueTrace: .empty,
            oxygenExposure: .unavailable(reason: .invalidInput),
            ppO2Timeline: [],
            ppN2Timeline: [],
            endTimeline: [],
            gasDensityTimeline: [],
            cnsTimeline: [],
            warnings: [],
            validationResult: validation,
            engineSegments: [],
            ttsMinutes: 0,
            totalRuntimeMinutes: 0,
            decoStops: [],
            depthProfilePoints: [],
            buhlmannState: .invalidInput
        )
    }
}
