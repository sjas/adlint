Feature: W0783

  W0783 detects that a cast-expression contains a pointer type of an incomplete
  type.

  Scenario: casting to a pointer of an incomplete struct
    Given a target source named "fixture.c" with:
      """
      extern struct Foo *gp;

      void foo(int *p)
      {
          gp = (struct Foo *) p; /* W0783 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 20     |
      | W0117 | 3    | 6      |
      | W0783 | 5    | 10     |
      | W0104 | 3    | 15     |
      | W0105 | 3    | 15     |
      | W0628 | 3    | 6      |

  Scenario: casting from a pointer of an incomplete struct
    Given a target source named "fixture.c" with:
      """
      extern struct Foo *gp;

      void foo(void)
      {
          int *p = (int *) gp; /* W0783 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 20     |
      | W0117 | 3    | 6      |
      | W0783 | 5    | 14     |
      | W0100 | 5    | 10     |
      | W0628 | 3    | 6      |

  Scenario: casting from and to a pointer of an incomplete struct
    Given a target source named "fixture.c" with:
      """
      extern struct Foo *p1;
      extern union Bar *p2;

      void foo(void)
      {
          p2 = (union Bar *) p1; /* W0783 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 20     |
      | W0118 | 2    | 19     |
      | W0117 | 4    | 6      |
      | W0783 | 6    | 10     |
      | W0628 | 4    | 6      |

  Scenario: casting from and to a pointer of an complete type
    Given a target source named "fixture.c" with:
      """
      struct Foo {
          int i;
      } *p1;

      union Bar {
          int i;
          char c;
      } *p2;

      void foo(void)
      {
          p2 = (union Bar *) p1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 4      |
      | W0117 | 8    | 4      |
      | W0117 | 10   | 6      |
      | W0551 | 5    | 7      |
      | W0628 | 10   | 6      |
      | W0589 | 3    | 4      |
      | W0593 | 3    | 4      |
      | W0589 | 8    | 4      |
      | W0593 | 8    | 4      |
