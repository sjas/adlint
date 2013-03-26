Feature: W1076

  W1076 detects that a `static' function definition appears with no anterior
  function declarations.

  Scenario: `static' function definition
    Given a target source named "fixture.c" with:
      """
      static int foo(void) /* W1076 */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: `static' function declaration followed by the `static' function
            definition
    Given a target source named "fixture.c" with:
      """
      static int foo(void);

      static int foo(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: `extern' function definition
    Given a target source named "fixture.c" with:
      """
      extern int foo(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: function definition without storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      int foo(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0628 | 1    | 5      |
