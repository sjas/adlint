Feature: W0067

  W0067 detects that the nested member of a composite data type is accessed
  directly without parent member names.

  Scenario: no direct access
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          struct {
              int i;
              struct {
                  int j;
              } baz;
          } bar = { 0, { 0 } };

          return bar.i + bar.baz.j; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0100 | 8    | 7      |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: direct access to nested member included in a named member
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          struct {
              int i;
              struct {
                  int j;
              } baz;
          } bar = { 0, { 0 } };

          return bar.i + bar.j; /* W0067 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0067 | 10   | 23     |
      | W0100 | 8    | 7      |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: direct access to nested member included in an unnamed member
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          struct {
              int i;
              struct {
                  int j;
              };
          } bar = { 0, { 0 } };

          return bar.i + bar.j; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0100 | 8    | 7      |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |
