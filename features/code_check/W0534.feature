Feature: W0534

  W0534 detects that a controlling variable of for-statement is not initialized
  in the 1st part of for-statement.

  Scenario: the 1st part of for-statement does not initialize the controlling
            variable
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int i = 0, j;
          for (j = 0; (bar(&i)) && (i < num); i++) { /* W0534 */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0534 | 6    | 10     |
      | W0629 | 3    | 12     |
      | W0425 | 5    | 16     |
      | W0628 | 3    | 12     |

  Scenario: the 1st part of for-statement is empty
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int i = 0, j = 0;
          for (; (bar(&i)) && (i < num); i++) { /* W0534 */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0534 | 6    | 10     |
      | W0629 | 3    | 12     |
      | W0425 | 5    | 16     |
      | W0628 | 3    | 12     |

  Scenario: the 1st part of for-statement initializes the controlling variable
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int i, j = 0;
          for (i = 0; (bar(&i)) && (i < num); i++) { /* OK */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0425 | 5    | 12     |
      | W0628 | 3    | 12     |
