Feature: W1068

  W1068 detects that a value of the `double' typed compound expression is
  explicitly converted into a `long double' value.

  Scenario: explicit conversion from `double' to `long double' when the source
            value is derived from `+', `-', `*' or `/' expressions
    Given a target source named "fixture.c" with:
      """
      static void func(double a, double b)
      {
          long double c;
          c = (long double) (a + b); /* W1068 */
          c = (long double) (a - b); /* W1068 */
          c = (long double) (a * b); /* W1068 */
          c = (long double) (a / b); /* W1068 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 4    | 26     |
      | W1068 | 4    | 26     |
      | W0723 | 5    | 26     |
      | W1068 | 5    | 26     |
      | W0723 | 6    | 26     |
      | W1068 | 6    | 26     |
      | W0093 | 7    | 26     |
      | C1000 |      |        |
      | C1006 | 1    | 35     |
      | W1068 | 7    | 26     |
      | W0104 | 1    | 25     |
      | W0104 | 1    | 35     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: explicit conversion from `double' to `long double' when the source
            value is not derived from `+', `-', `*' or `/' expressions
    Given a target source named "fixture.c" with:
      """
      static void func(double a, double b)
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
      | C1000 |      |        |
      | C1006 | 1    | 35     |
      | W0570 | 6    | 26     |
      | C1000 |      |        |
      | C1006 | 1    | 25     |
      | W0572 | 6    | 26     |
      | W0794 | 6    | 26     |
      | W0572 | 7    | 26     |
      | W0104 | 1    | 25     |
      | W0104 | 1    | 35     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: implicit conversion from `double' to `long double'
    Given a target source named "fixture.c" with:
      """
      static void func(double a, double b)
      {
          long double c;
          c = a + b; /* W0779 */
          c = a - b; /* W0779 */
          c = a * b; /* W0779 */
          c = a / b; /* W0779 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 4    | 11     |
      | W0779 | 4    | 11     |
      | W0723 | 5    | 11     |
      | W0779 | 5    | 11     |
      | W0723 | 6    | 11     |
      | W0779 | 6    | 11     |
      | W0093 | 7    | 11     |
      | C1000 |      |        |
      | C1006 | 1    | 35     |
      | W0779 | 7    | 11     |
      | W0104 | 1    | 25     |
      | W0104 | 1    | 35     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
