Feature: W0460

  W0460 detects that a value of the variable is not possibly initialized.

  Scenario: array element is not possibly initialized
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int a[5];

          if (a[1] == 0) { /* W0459 */
              a[0] = 0;
          }

          return a[0]; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0459 | 5    | 14     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0460 | 9    | 13     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1002 | 5    | 14     |
      | W0629 | 1    | 12     |
      | W0950 | 3    | 11     |
      | W0628 | 1    | 12     |

  Scenario: possible uninitialized value reference because of an incomplete if
            statement
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int j;

          if (i == 0) { /* false */
              j = 0;
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0460 | 9    | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1002 | 5    | 11     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 6      |

  Scenario: possible uninitialized value reference because of an incomplete if
            statement
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int j;

          if (i < 0) { /* false */
              j = 1;
              if (i < -10) {
                  j = 2;
              }
              else if (i < -5) {
                  j = 3;
              }
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0460 | 15   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1002 | 5    | 11     |
      | W0104 | 1    | 14     |
      | W1069 | 7    | 9      |
      | W0628 | 1    | 6      |

  Scenario: possible uninitialized value reference because of an incomplete
            if-else-if statement
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int j;

          if (i < 0) { /* true */
              if (i < -10) { /* false */
                  j = 2;
              }
              else if (i < -5) { /* false */
                  j = 3;
              }
          }
          else {
              j = 1;
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0460 | 17   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1001 | 5    | 11     |
      | C1002 | 6    | 15     |
      | C1002 | 9    | 20     |
      | W0104 | 1    | 14     |
      | W1069 | 6    | 9      |
      | W0628 | 1    | 6      |

  Scenario: possible uninitialized value reference because of an incomplete if
            statement
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int j;

          if (i < 0) { /* false */
              if (i < -10) {
                  j = 2;
              }
              else if (i < -5) {
                  j = 3;
              }
              else {
                  j = 1;
              }
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0460 | 17   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1002 | 5    | 11     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 6      |

  Scenario: possible uninitialized value reference because of missing
            assignment in a complete if statement
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int j;

          if (i < 0) { /* true */
              if (i < -10) { /* false */
                  j = 2;
              }
              else if (i < -5) { /* false */
                  j = 3;
              }
              else {
              }
          }
          else {
              j = 1;
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0460 | 19   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1001 | 5    | 11     |
      | C1002 | 6    | 15     |
      | C1002 | 9    | 20     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 6      |

  Scenario: possible uninitialized value reference because of an incomplete if
            statement
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          int j;

          if (i < 0) { /* false */
              j = 1;
              if (i < -10) {
                  j = 2;
              }
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0460 | 12   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1002 | 5    | 11     |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 6      |

  Scenario: possible uninitialized value reference because of an incomplete
            if-else-if statement
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j;

          if (i > 2) { /* true */
              if (i == 5) { /* false */
                  j = 5;
              }
              else if (i == 6) { /* false */
                  j = 6;
              }
          }
          else if (i < 0) {
              j = -1;
          }

          return j; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0460 | 17   | 12     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | C1001 | 5    | 11     |
      | C1002 | 6    | 15     |
      | C1002 | 9    | 20     |
      | W0104 | 1    | 13     |
      | W1069 | 5    | 5      |
      | W1069 | 6    | 9      |
      | W0628 | 1    | 5      |

  Scenario: variable is not possibly initialized because of an incomplete
            selection statement
    Given a target source named "fixture.c" with:
      """
      struct bar {
          int x;
          int y;
      };
      
      struct bar a[3];
      
      int foo(int i, int j)
      {
          int k;
      
          if (i < 0) {
              struct bar b;
              if (j == 0) {
                  return 0;
              }
              k = j < 10 ? b.x : b.y;
          }
          else if (i > 10) {
              k = j ? a[0].x : a[1].y;
          }
      
          return k; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 6    | 12     |
      | W0117 | 8    | 5      |
      | W0459 | 17   | 20     |
      | C1000 |      |        |
      | C1003 | 13   | 20     |
      | W0100 | 13   | 20     |
      | W0460 | 23   | 12     |
      | C1000 |      |        |
      | C1003 | 10   | 9      |
      | C1002 | 12   | 11     |
      | C1002 | 19   | 16     |
      | W0104 | 8    | 13     |
      | W0104 | 8    | 20     |
      | W1071 | 8    | 5      |
      | W0950 | 6    | 14     |
      | W1069 | 12   | 5      |
      | W0501 | 17   | 20     |
      | W0114 | 20   | 13     |
      | W0628 | 8    | 5      |
      | W0589 | 6    | 12     |
      | W0593 | 6    | 12     |

  Scenario: variable is initialized by a complete selection statement
    Given a target source named "fixture.c" with:
      """
      struct bar {
          int x;
          int y;
      };
      
      struct bar a[3];
      
      int foo(int i, int j)
      {
          int k;
      
          if (i < 0) {
              struct bar b;
              if (j == 0) {
                  return 0;
              }
              k = j < 10 ? b.x : b.y;
          }
          else {
              k = j ? a[0].x : a[1].y;
          }
      
          return k; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 6    | 12     |
      | W0117 | 8    | 5      |
      | W0459 | 17   | 20     |
      | C1000 |      |        |
      | C1003 | 13   | 20     |
      | W0100 | 13   | 20     |
      | W0104 | 8    | 13     |
      | W0104 | 8    | 20     |
      | W1071 | 8    | 5      |
      | W0950 | 6    | 14     |
      | W0501 | 17   | 20     |
      | W0114 | 20   | 13     |
      | W0628 | 8    | 5      |
      | W0589 | 6    | 12     |
      | W0593 | 6    | 12     |
