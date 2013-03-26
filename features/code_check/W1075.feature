Feature: W1075

  W1075 detects that a declaration has no `static' specifier while the anterior
  declaration is specified as `static'.

  Scenario: colliding global variable declarations
    Given a target source named "fixture.c" with:
      """
      static int i;
      extern int i; /* W1075 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1031 | 2    | 12     |
      | W1075 | 2    | 12     |

  Scenario: `static' function declaration followed by its definition without
            storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      static int foo(void);

      int foo(void) /* W1075 */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1075 | 3    | 5      |
      | W0629 | 3    | 5      |
      | W0628 | 3    | 5      |

  Scenario: colliding function declarations with `static' and `extern'
    Given a target source named "fixture.c" with:
      """
      static int foo(void);

      extern int foo(void) /* W1075 */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1031 | 3    | 12     |
      | W1075 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: all function declarations with `static'
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

  Scenario: all function declarations with `extern'
    Given a target source named "fixture.c" with:
      """
      extern int foo(void);

      extern int foo(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0628 | 3    | 12     |
