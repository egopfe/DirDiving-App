# RUN SEQUENCE V3.0

Run one command at a time on a clean `main` checkout.

```text
0 → 0W → 01W → 1 → 2 → 15 → 18 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 16
```

After each audit:

1. archive the generated reports;
2. review P0/P1 findings;
3. do not launch remediation from the audit command;
4. create separate remediation commands;
5. rerun the relevant vertical audit after remediation;
6. run command 12 before claiming 100%;
7. run command 13 before external release.
