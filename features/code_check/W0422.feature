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
      | W1076 | 10   | 12     |
      | W0422 | 13   | 13     |
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
