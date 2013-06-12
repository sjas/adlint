Feature: W0459

  W0459 detects that the variable is not initialized at point of the expression
  evaluation.

  Scenario: variable initialization by a function via the output parameter
    Given a target source named "fixture.c" with:
      """
      extern void foo(int ***);
      extern void bar(int **);

      void baz(int i)
      {
          int **p;
          foo(i == 0 ? NULL : &p);
          bar(p);
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0118 | 2    | 13     |
      | W0117 | 4    | 6      |
      | W0459 | 7    | 25     |
      | W9003 | 7    | 16     |
      | W0100 | 6    | 11     |
      | W0104 | 4    | 14     |
      | W0501 | 7    | 16     |
      | W0628 | 4    | 6      |
