Feature: W0703

  W0703 detects that a tag name is hiding other tag names.

  Scenario: tag hiding declaration in function-definition
    Given a target source named "fixture.c" with:
      """
      struct Foo {
          int i;
      };

      int main(void)
      {
          union Foo { /* W0703 */
              int i;
              int j;
          } foo = { 0 };

          return foo.i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0703 | 7    | 11     |
      | C0001 | 1    | 8      |
      | W0785 | 7    | 11     |
      | W0552 | 10   | 7      |
      | W0100 | 10   | 7      |
      | W0551 | 7    | 11     |

  Scenario: tag hiding declaration in the global scope
    Given a target source named "fixture.c" with:
      """
      struct Foo {
          int i;
      };

      static union Foo { /* W0703 */
          int i;
          int j;
      } foo = { 0 };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0703 | 5    | 14     |
      | C0001 | 1    | 8      |
      | W0785 | 5    | 14     |
      | W0552 | 8    | 3      |
      | W0551 | 5    | 14     |

  Scenario: enum declaration in global and function scope
    Given a target source named "fixture.c" with:
      """
      enum E { FOO, BAR };

      int main(void)
      {
          enum E { BAR, BAZ } e = FOO; /* W0703 */
          return e;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0703 | 5    | 10     |
      | C0001 | 1    | 6      |
      | W0704 | 5    | 14     |
      | C0001 | 1    | 15     |
      | W0785 | 5    | 10     |
      | W0789 | 5    | 14     |
      | C0001 | 1    | 15     |
      | W9003 | 6    | 12     |
      | W1060 | 6    | 12     |
      | W0100 | 5    | 25     |
