Feature: W0478

  W0478 detects that the macro defined as an unrecognizable piece of code.

  Scenario: including `{}' and control statement
    Given a target source named "fixture.c" with:
      """
      #define CHECK(ptr) if (!ptr) { exit(1) }; /* W0478 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 25     |
      | W0478 | 1    | 1      |

  Scenario: including semicolon and control statement
    Given a target source named "fixture.c" with:
      """
      #define CHECK(ptr) ptr = malloc(size); if (!ptr) exit(1);/* W0478 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 20     |
      | W0549 | 1    | 45     |
      | W0478 | 1    | 1      |

  Scenario: including storage-class specifier
    Given a target source named "fixture.c" with:
      """
      #define CONV(num) return (static int) (num) /* W0478 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0478 | 1    | 1      |

  Scenario: including `{]',but it also including initializer
    Given a target source named "fixture.c" with:
      """
      #define SUM(num) { num, num + 10 } /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 20     |
      | W0549 | 1    | 25     |

  Scenario: including `{]',but it also including code block
    Given a target source named "fixture.c" with:
      """
      #define INI(x, n) {int i; for (i = 0; i < n; ++i) { x[i] = 0; }} /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 53     |
      | W0549 | 1    | 43     |
      | W0481 | 1    | 1      |

  Scenario: including `{}' but have `do-while-zero' structure
    Given a target source named "fixture.c" with:
      """
      #define DO_WHILE(x) do { x = x + 1 } while (0) /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 26     |
      | W0549 | 1    | 30     |

  Scenario: have the semicolon but it's list of specifier and qualifier
    Given a target source named "fixture.c" with:
      """
      #define U_INT unsigned int; /* OK */
      #define C_INT const int;    /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |
      | W0479 | 2    | 1      |

  Scenario: have the semicolon but it's list of storage-class specifier and
            type specifier
    Given a target source named "fixture.c" with:
      """
      #define CONV(x) static const int y = x; return y; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 38     |
