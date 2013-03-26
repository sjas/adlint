Feature: W1067

  W1067 detects that a value of the `float' typed compound expression is
  explicitly converted into a `long double' value.

  Scenario: explicit conversion from `float' to `double' when the source value
            is derived from `+', `-', `*' or `/' expressions
    Given a target source named "fixture.c" with:
      """
      static void func(float a, float b)
      {
          long double c;
          c = (long double) (a + b); /* W1067 */
          c = (long double) (a - b); /* W1067 */
          c = (long double) (a * b); /* W1067 */
          c = (long double) (a / b); /* W1067 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 4    | 26     |
      | W1067 | 4    | 26     |
      | W0723 | 5    | 26     |
      | W1067 | 5    | 26     |
      | W0723 | 6    | 26     |
      | W1067 | 6    | 26     |
      | W0093 | 7    | 26     |
      | W1067 | 7    | 26     |
      | W0104 | 1    | 24     |
      | W0104 | 1    | 33     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: explicit conversion from `float' to `double' when the source value
            is not derived from `+', `-', `*' or `/' expressions
    Given a target source named "fixture.c" with:
      """
      static void func(float a, float b)
      {
          long double c;
          c = (long double) (a % b); /* OK */
          c = (long double) (a < b); /* OK */
          c = (long double) (a << b); /* OK */
          c = (long double) (a ^ b); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0093 | 4    | 26     |
      | W0570 | 6    | 26     |
      | W0572 | 6    | 26     |
      | W0794 | 6    | 26     |
      | W0572 | 7    | 26     |
      | W0104 | 1    | 24     |
      | W0104 | 1    | 33     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: implicit conversion from `float' to `long double'
    Given a target source named "fixture.c" with:
      """
      static void func(float a, float b)
      {
          long double c;
          c = a + b; /* W0778 */
          c = a - b; /* W0778 */
          c = a * b; /* W0778 */
          c = a / b; /* W0778 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 4    | 11     |
      | W0778 | 4    | 11     |
      | W0723 | 5    | 11     |
      | W0778 | 5    | 11     |
      | W0723 | 6    | 11     |
      | W0778 | 6    | 11     |
      | W0093 | 7    | 11     |
      | W0778 | 7    | 11     |
      | W0104 | 1    | 24     |
      | W0104 | 1    | 33     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
