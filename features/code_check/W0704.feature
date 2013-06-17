Feature: W0704

  W0704 detects that an ordinary identifier is hiding other identifier.

  Scenario: hiding typedef name by enumerator name
    Given a target source named "fixture.c" with:
      """
      typedef double DOUBLE;

      void foo(void)
      {
          enum arg_type { INT, DOUBLE } type;
          type = DOUBLE;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0704 | 5    | 26     |
      | C0001 | 1    | 16     |
      | W0789 | 5    | 26     |
      | C0001 | 1    | 16     |
      | W0100 | 5    | 35     |
      | W0628 | 3    | 6      |
