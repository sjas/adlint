Feature: W0722

  W0722 detects that signed arithmetic-expression must overflow.

  Scenario: additive-expression must not overflow
    Given a target source named "fixture.c" with:
      """
      static int foo(int i, int j)
      {
          if ((i > -10) && (i < 10) && (j > -20) && (j < 20)) {
              return i + j; /* OK */
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: additive-expression may overflow
    Given a target source named "fixture.c" with:
      """
      static int foo(int i, int j)
      {
          if ((i > -10) && (i < 10) && (j < 20)) {
              return i + j; /* OK but W0723 */
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 4    | 18     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: additive-expression must overflow
    Given a target source named "fixture.c" with:
      """
      static int foo(int i, int j)
      {
          if ((i > 2000000000) && (j > 2000000000)) {
              return i + j; /* W0722 */
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0722 | 4    | 18     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |
