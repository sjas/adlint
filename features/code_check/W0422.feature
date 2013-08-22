Feature: W0422

  W0422 detects that an inconstant expression may cause NULL pointer
  dereference.

  Scenario: pointer variable definition with self referring sizeof-expression
            in the initializer
    Given a target source named "fixture.c" with:
      """
      struct foo { int i; };
      extern void *malloc(unsigned long);

      static int bar(void)
      {
          struct foo * const p = (struct foo *) malloc(sizeof *p);
          return p->i; /* W0422 */
      }

      static int baz(void)
      {
          struct foo * const p = (struct foo *) malloc(sizeof(struct foo));
          return p->i; /* W0422 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 2    | 14     |
      | W1076 | 4    | 12     |
      | W0422 | 7    | 13     |
      | C1000 |      |        |
      | C1005 | 6    | 24     |
      | W1076 | 10   | 12     |
      | W0422 | 13   | 13     |
      | C1000 |      |        |
      | C1005 | 12   | 24     |
      | W0629 | 4    | 12     |
      | W0629 | 10   | 12     |
      | W0628 | 4    | 12     |
      | W0628 | 10   | 12     |

  Scenario: pointer variable as a part of controlling expression
    Given a target source named "fixture.c" with:
      """
      struct node { struct node *prev; };

      void foo(const struct node *list)
      {
          if (list != NULL)
          {
              while (1)
              {
                  list = list->prev; /* OK */
                  if (list == NULL)
                  {
                      break;
                  }
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0114 | 7    | 9      |
      | W0628 | 3    | 6      |

  Scenario: pointer variable as a part of controlling expression is declared in
            the iteration body
    Given a target source named "fixture.c" with:
      """
      static int *bar(void);

      void foo(void)
      {
          if (1) {
              int *p1;
              p1 = bar();
              while (1) {
                  int *p2;
                  p2 = p1;
                  while (*p2 != 3) { /* W0422 */
                      p2++;
                  }
                  if (*p2 == 4) {
                      break;
                  }
                  else {
                      p1 = bar();
                  }
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0422 | 11   | 20     |
      | C1000 |      |        |
      | C1001 | 5    | 9      |
      | C1005 | 9    | 18     |
      | C1005 | 10   | 16     |
      | W0024 | 12   | 19     |
      | W0114 | 5    | 5      |
      | W0114 | 8    | 9      |
      | W0628 | 3    | 6      |

  Scenario: pointer variable has the same name with previously declared
            function
    Given a target source named "fixture.c" with:
      """
      extern void instr(void);

      void foo(char *instr)
      {
          if (instr[0] == '*') { /* W0422 */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0704 | 3    | 16     |
      | C0001 | 1    | 13     |
      | W0422 | 5    | 14     |
      | C1000 |      |        |
      | C1005 | 3    | 16     |
      | W0123 | 5    | 14     |
      | W0104 | 3    | 16     |
      | W0105 | 3    | 16     |
      | W1071 | 3    | 6      |
      | W0948 | 5    | 21     |
      | W0628 | 3    | 6      |

  Scenario: value of the global pointer is correctly null-checked by the
            controlling-expression of while-statement
    Given a target source named "fixture.c" with:
      """
      int *ptr = NULL;

      static void foo(void)
      {
          while (ptr) {
              int i, *p = ptr;
              i = *p; /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1076 | 3    | 13     |
      | W0100 | 6    | 17     |
      | W0629 | 3    | 13     |
      | W0114 | 5    | 5      |
      | W0425 | 6    | 17     |
      | W0628 | 3    | 13     |
      | W0589 | 1    | 6      |
      | W0593 | 1    | 6      |

  Scenario: global pointer array as the controlling-expression of if-statement
    Given a target source named "fixture.c" with:
      """
      int *a[3] = { 0 };

      int foo(void)
      {
          if (a[2] == NULL) {
              return *a[2];
          }
          else if (a[2] == 1) {
              return *a[2];
          }
          return *a[2]; /* OK not W0422 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0117 | 3    | 5      |
      | W0421 | 6    | 16     |
      | C1000 |      |        |
      | C1004 | 1    | 6      |
      | W9003 | 8    | 22     |
      | W0027 | 8    | 19     |
      | W1071 | 3    | 5      |
      | W0950 | 1    | 8      |
      | W1069 | 5    | 5      |
      | W0628 | 3    | 5      |
      | W0589 | 1    | 6      |
      | W0593 | 1    | 6      |

  Scenario: global pointer as the controlling-expression of if-statement
    Given a target source named "fixture.c" with:
      """
      int *ptr = 0;

      int bar(void)
      {
          if (ptr == NULL) {
              return *ptr;
          }
          else if (ptr == 1) {
              return *ptr;
          }
          return *ptr; /* OK not W0422 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0117 | 3    | 5      |
      | W0421 | 6    | 16     |
      | C1000 |      |        |
      | C1004 | 1    | 6      |
      | W9003 | 8    | 21     |
      | W0027 | 8    | 18     |
      | W1071 | 3    | 5      |
      | W1069 | 5    | 5      |
      | W0628 | 3    | 5      |
      | W0589 | 1    | 6      |
      | W0593 | 1    | 6      |

  Scenario: global pointer as the controlling-expression of if-statement in an
            iteration-statement
    Given a target source named "fixture.c" with:
      """
      int *a[3] = { 0 };

      int foo(unsigned int ui)
      {
          for (; ui < 3; ui++) {
              if (a[ui] == NULL) {
                  break;
              }
              return *a[ui]; /* OK not W0422 */
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0117 | 3    | 5      |
      | W0534 | 5    | 10     |
      | W0167 | 5    | 17     |
      | W0147 | 6    | 15     |
      | W0147 | 9    | 19     |
      | W0104 | 3    | 22     |
      | W1071 | 3    | 5      |
      | W0950 | 1    | 8      |
      | W0628 | 3    | 5      |
      | W0589 | 1    | 6      |
      | W0593 | 1    | 6      |

  Scenario: global pointer as the controlling-expression of if-statement in an
            iteration-statement
    Given a target source named "fixture.c" with:
      """
      int *ptr = 0;

      int bar(unsigned int ui)
      {
          for (; ui < 3; ui++) {
              if (ptr == NULL) {
                  break;
              }
              else if (ptr == 1) {
                  return *ptr; /* OK */
              }
              return *ptr; /* OK not W0422 */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0117 | 3    | 5      |
      | W0534 | 5    | 10     |
      | W0167 | 5    | 17     |
      | W9003 | 9    | 25     |
      | W0027 | 9    | 22     |
      | W0697 | 3    | 5      |
      | W0104 | 3    | 22     |
      | W1071 | 3    | 5      |
      | W1069 | 6    | 9      |
      | W0628 | 3    | 5      |
      | W0589 | 1    | 6      |
      | W0593 | 1    | 6      |

  Scenario: possible null-dereference because of an incomplete if statement
    Given a target source named "fixture.c" with:
      """
      int *bar(void);

      int foo(int i)
      {
          int *p;

          if (i == 0) { /* true */
              p = bar();
          }

          return *p; /* W0422 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 6      |
      | W0117 | 3    | 5      |
      | W0460 | 11   | 12     |
      | C1000 |      |        |
      | C1003 | 5    | 10     |
      | C1002 | 7    | 11     |
      | W0422 | 11   | 12     |
      | C1000 |      |        |
      | C1005 | 5    | 10     |
      | C1001 | 7    | 11     |
      | C1005 | 8    | 11     |
      | W0100 | 5    | 10     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: possible null-dereference because of an incomplete selection
            statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i;
          int *p;

          switch (rand()) {
          case 0: /* false */
              p = &i;
              break;
          case 1: /* true */
              p = NULL;
              break;
          default:
              return;
          }

          *p = 5; /* W0422 */

          if (i < rand()) { /* false */
              p = &i;
          }

          *p = 6; /* W0422 */

          if (rand() < 1) { /* false */
              p = &i;
          }

          *p = 7; /* W0422 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0109 | 6    | 13     |
      | W0459 | 8    | 13     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0422 | 17   | 5      |
      | C1000 |      |        |
      | C1005 | 4    | 10     |
      | C1002 | 7    | 5      |
      | C1001 | 10   | 5      |
      | C1004 | 11   | 11     |
      | W0459 | 19   | 11     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0459 | 20   | 13     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0422 | 23   | 5      |
      | C1000 |      |        |
      | C1005 | 4    | 10     |
      | C1002 | 7    | 5      |
      | C1001 | 10   | 5      |
      | C1004 | 11   | 11     |
      | C1002 | 19   | 11     |
      | W0459 | 26   | 13     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0422 | 29   | 5      |
      | C1000 |      |        |
      | C1005 | 4    | 10     |
      | C1002 | 7    | 5      |
      | C1001 | 10   | 5      |
      | C1004 | 11   | 11     |
      | C1002 | 19   | 11     |
      | C1002 | 25   | 16     |
      | W0100 | 3    | 9      |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: possible null-dereference because of an incomplete iteration
            statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          int i;
          int *p;

          switch (rand()) {
          case 0: /* false */
              p = &i;
              break;
          case 1: /* true */
              p = NULL;
              break;
          default:
              return;
          }

          *p = 5; /* W0422 */

          for (i = 0; i < rand(); ++i) { /* false */
              p = &i;
          }

          *p = 6; /* W0422 */

          while (rand() < 1) { /* false */
              p = &i;
          }

          *p = 7; /* W0422 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0109 | 6    | 13     |
      | W0459 | 8    | 13     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0422 | 17   | 5      |
      | C1000 |      |        |
      | C1005 | 4    | 10     |
      | C1002 | 7    | 5      |
      | C1001 | 10   | 5      |
      | C1004 | 11   | 11     |
      | W0422 | 23   | 5      |
      | C1000 |      |        |
      | C1005 | 4    | 10     |
      | C1002 | 7    | 5      |
      | C1001 | 10   | 5      |
      | C1004 | 11   | 11     |
      | C1002 | 19   | 19     |
      | W0422 | 29   | 5      |
      | C1000 |      |        |
      | C1005 | 4    | 10     |
      | C1002 | 7    | 5      |
      | C1001 | 10   | 5      |
      | C1004 | 11   | 11     |
      | C1002 | 19   | 19     |
      | C1002 | 25   | 19     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
