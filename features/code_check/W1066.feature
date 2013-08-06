Feature: W1066

  W1066 detects that a value of the `float' typed compound expression is
  explicitly converted into a `double' value.

  Scenario: explicit conversion from `float' to `double' when the source value
            is derived from `+', `-', `*' or `/' expressions
    Given a target source named "fixture.c" with:
      """
      static void func(float a, float b)
      {
          double c;
          c = (double) (a + b); /* W1066 */
          c = (double) (a - b); /* W1066 */
          c = (double) (a * b); /* W1066 */
          c = (double) (a / b); /* W1066 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 4    | 21     |
      | W1066 | 4    | 21     |
      | W0723 | 5    | 21     |
      | W1066 | 5    | 21     |
      | W0723 | 6    | 21     |
      | W1066 | 6    | 21     |
      | W0093 | 7    | 21     |
      | C1000 |      |        |
      | C1006 | 1    | 33     |
      | W1066 | 7    | 21     |
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
          double c;
          c = (double) (a % b); /* OK */
          c = (double) (a < b); /* OK */
          c = (double) (a << b); /* OK */
          c = (double) (a ^ b); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0093 | 4    | 21     |
      | C1000 |      |        |
      | C1006 | 1    | 33     |
      | W0570 | 6    | 21     |
      | C1000 |      |        |
      | C1006 | 1    | 24     |
      | W0572 | 6    | 21     |
      | W0794 | 6    | 21     |
      | W0572 | 7    | 21     |
      | W0104 | 1    | 24     |
      | W0104 | 1    | 33     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: implicit conversion from `float' to `double'
    Given a target source named "fixture.c" with:
      """
      static void func(float a, float b)
      {
          double c;
          c = a + b; /* W0777 */
          c = a - b; /* W0777 */
          c = a * b; /* W0777 */
          c = a / b; /* W0777 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 4    | 11     |
      | W0777 | 4    | 11     |
      | W0723 | 5    | 11     |
      | W0777 | 5    | 11     |
      | W0723 | 6    | 11     |
      | W0777 | 6    | 11     |
      | W0093 | 7    | 11     |
      | C1000 |      |        |
      | C1006 | 1    | 33     |
      | W0777 | 7    | 11     |
      | W0104 | 1    | 24     |
      | W0104 | 1    | 33     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
