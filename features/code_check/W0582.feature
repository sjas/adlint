Feature: W0582

  W0582 detects that number or types of arguments of a function call does not
  conform with a prototype declaration of the function appears after the
  function call.

  Scenario: call with matched arguments
    Given a target source named "fixture.c" with:
      """
      static void foo(int *p)
      {
          bar(NULL, *p); /* OK */
      }

      static void bar(int *, int);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0422 | 3    | 15     |
      | C1000 |      |        |
      | C1006 | 1    | 22     |
      | W0109 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W1073 | 3    | 8      |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: call with unmatched arguments
    Given a target source named "fixture.c" with:
      """
      static void foo(int *p)
      {
          bar(NULL, p); /* W0582 */
      }

      static void bar(int *, int);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0109 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W1073 | 3    | 8      |
      | W0582 | 3    | 8      |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: call with unmatched constant pointer
    Given a target source named "fixture.c" with:
      """
      static void foo(int *p)
      {
          bar(3, *p); /* W0582 */
      }

      static void bar(int *, int);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0422 | 3    | 12     |
      | C1000 |      |        |
      | C1006 | 1    | 22     |
      | W0109 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W1073 | 3    | 8      |
      | W0582 | 3    | 8      |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
