Feature: W0097

  W0097 detects that a multiplicative-expression must cause division-by-zero.

  Scenario: dividing by global constant variable initialized with 0
    Given a target source named "fixture.c" with:
      """
      static const int i = 0;

      static int foo(void)
      {
          return 3 / i; /* W0097 */
      }

      static int bar(void)
      {
          return 3 / i; /* W0097 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0097 | 5    | 14     |
      | W1076 | 8    | 12     |
      | W0097 | 10   | 14     |
      | W0629 | 3    | 12     |
      | W0629 | 8    | 12     |
      | W0628 | 3    | 12     |
      | W0628 | 8    | 12     |
