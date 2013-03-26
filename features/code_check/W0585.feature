Feature: W0585

  W0585 detects that a controlling variable of for-statement is not updated in
  the 3rd part of for-statement.

  Scenario: the 3rd part of for-statement does not increment the controlling
            variable
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int i, j = 0;
          for (i = 0; (bar(&i)) && (i < num); j++) { /* W0585 */
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0585 | 6    | 42     |
      | W0629 | 3    | 12     |
      | W0425 | 5    | 12     |
      | W0628 | 3    | 12     |

  Scenario: the 3rd part of for-statement is empty
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int i, j = 0;
          for (i = 0; (bar(&i)) && (i < num); ) { /* OK */
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

  Scenario: the 3rd part of for-statement increments the controlling variable
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

  Scenario: the 3rd part of c99-for-statement does not increment the
            controlling variable
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int j = 0;
          for (int i = 0; (bar(&i)) && (i < num); j++) { /* W0585 */
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0585 | 6    | 46     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: the 3rd part of c99-for-statement is empty
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int j = 0;
          for (int i = 0; (bar(&i)) && (i < num); ) { /* OK */
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
      | W0628 | 3    | 12     |

  Scenario: the 3rd part of for-statement increments the controlling variable
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(const int num)
      {
          int j = 0;
          for (int i = 0; (bar(&i)) && (i < num); i++) { /* OK */
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
      | W0628 | 3    | 12     |
