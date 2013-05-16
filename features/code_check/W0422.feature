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
