Feature: W0584

  W0584 detects that type of the argument of a function call does not conform
  with one of the corresponding parameter of the old style function definition.

  Scenario: call with matched arguments
    Given a target source named "fixture.c" with:
      """
      int foo(p, i)
      int *p;
      int i;
      {
          return *p + i;
      }

      int bar(p)
      int *p;
      {
          return foo(NULL, *p); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0422 | 5    | 12     |
      | W0723 | 5    | 15     |
      | W0104 | 2    | 6      |
      | W0104 | 3    | 5      |
      | W0105 | 2    | 6      |
      | W0117 | 8    | 5      |
      | W0422 | 11   | 22     |
      | W0104 | 9    | 6      |
      | W0105 | 9    | 6      |
      | W0002 | 1    | 5      |
      | W0002 | 8    | 5      |
      | W0589 | 1    | 5      |
      | W0591 | 1    | 5      |
      | W0628 | 8    | 5      |

  Scenario: call with unmatched arguments
    Given a target source named "fixture.c" with:
      """
      int foo(p, i)
      int *p;
      int i;
      {
          return *p + i;
      }

      int bar(p)
      int *p;
      {
          return foo(NULL, p); /* W0584 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0422 | 5    | 12     |
      | W0723 | 5    | 15     |
      | W0104 | 2    | 6      |
      | W0104 | 3    | 5      |
      | W0105 | 2    | 6      |
      | W0117 | 8    | 5      |
      | W9003 | 11   | 22     |
      | W0584 | 11   | 22     |
      | W0104 | 9    | 6      |
      | W0105 | 9    | 6      |
      | W0002 | 1    | 5      |
      | W0002 | 8    | 5      |
      | W0589 | 1    | 5      |
      | W0591 | 1    | 5      |
      | W0628 | 8    | 5      |

  Scenario: call with unmatched constant pointer
    Given a target source named "fixture.c" with:
      """
      int foo(p, i)
      int *p;
      int i;
      {
          return *p + i;
      }

      int bar(p)
      int *p;
      {
          return foo(3, *p); /* W0584 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0422 | 5    | 12     |
      | W0723 | 5    | 15     |
      | W0104 | 2    | 6      |
      | W0104 | 3    | 5      |
      | W0105 | 2    | 6      |
      | W0117 | 8    | 5      |
      | W0422 | 11   | 19     |
      | W9003 | 11   | 16     |
      | W0584 | 11   | 16     |
      | W0104 | 9    | 6      |
      | W0105 | 9    | 6      |
      | W0002 | 1    | 5      |
      | W0002 | 8    | 5      |
      | W0589 | 1    | 5      |
      | W0591 | 1    | 5      |
      | W0628 | 8    | 5      |

  Scenario: call with convertible arguments
    Given a target source named "fixture.c" with:
      """
      void print(p)
      const char *p;
      {
      }

      void foo()
      {
          print("foo"); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0031 | 2    | 13     |
      | W0104 | 2    | 13     |
      | W0117 | 6    | 6      |
      | W0002 | 1    | 6      |
      | W0540 | 6    | 6      |
      | W0947 | 8    | 11     |
      | W0589 | 1    | 6      |
      | W0591 | 1    | 6      |
      | W0628 | 6    | 6      |
