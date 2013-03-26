Feature: W0425

  W0425 detects that two or more declarations or statements are in a line.

  Scenario: two declarations in a line
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          int i = 0; int j = 0; /* W0425 */
          return i + j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 9      |
      | W0100 | 3    | 20     |
      | W0425 | 3    | 20     |
      | W0628 | 1    | 5      |

  Scenario: two declarators in a declaration
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          int i = 0, j = 0; /* W0425 */
          return i + j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 9      |
      | W0100 | 3    | 16     |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 5      |

  Scenario: a declaration and a jump-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          int i = 0; return i + 1; /* W0425 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 9      |
      | W0425 | 3    | 16     |
      | W0628 | 1    | 5      |

  Scenario: a expression-statement and a jump-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          int i;
          i = 0; return i + 1; /* W0425 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 9      |
      | W0425 | 4    | 12     |
      | W0628 | 1    | 5      |

  Scenario: a if-else-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          if (i == 0) return 0; else return 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0414 | 3    | 17     |
      | W0414 | 3    | 32     |
      | W0628 | 1    | 5      |

  Scenario: a if-else-statement with compound-statements in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          if (i == 0) { return 0; } else { return 1; } /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: a if-statement with compound-statements in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          if (i == 0) { return 0; } /* OK */
          return 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: a if-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          if (i == 0) return 0; /* OK */
          return 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0414 | 3    | 17     |
      | W0628 | 1    | 5      |

  Scenario: a for-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j, k = 1; /* W0425 */
          for (j = 0; j < i; j++) k *= 2; /* OK */
          return k;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W0414 | 4    | 29     |
      | W0425 | 3    | 12     |
      | W0628 | 1    | 5      |

  Scenario: a for-statement with a compound-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j, k = 1; /* W0425 */
          for (j = 0; j < i; j++) { k *= 2; } /* OK */
          return k;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W0425 | 3    | 12     |
      | W0628 | 1    | 5      |

  Scenario: extra statement after if-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          if (i == 0) return 0; return 1; /* W0425 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0414 | 3    | 17     |
      | W0425 | 3    | 27     |
      | W0628 | 1    | 5      |

  Scenario: extra statement after for-statement in a line
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j, k = 1; /* W0425 */
          for (j = 0; j < i; j++) k *= 2; return k; /* W0425 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W0414 | 4    | 29     |
      | W0425 | 3    | 12     |
      | W0425 | 4    | 37     |
      | W0628 | 1    | 5      |

  Scenario: two member-declarations in a line
    Given a target source named "fixture.c" with:
      """
      struct foo { int i; int j; }; /* W0425 */
      union bar { int i; int j; }; /* W0425 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0551 | 2    | 7      |
      | W0425 | 1    | 25     |
      | W0425 | 2    | 24     |

  Scenario: two declarators in a member-declaration
    Given a target source named "fixture.c" with:
      """
      struct foo { int *p, i; }; /* W0425 */
      union bar { int *p, i; }; /* W0425 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0551 | 2    | 7      |
      | W0425 | 1    | 22     |
      | W0425 | 2    | 21     |

  Scenario: two declarators in a member-declaration
    Given a target source named "fixture.c" with:
      """
      extern struct { int i; } foo; /* OK */
      extern union { int i; } bar; /* OK */
      typedef struct { int i; } baz; /* OK */
      typedef union { int i; } qux; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 26     |
      | W0118 | 2    | 25     |
      | W0551 | 2    | 8      |
      | W0551 | 4    | 9      |

  Scenario: two declarators in a member-declaration
    Given a target source named "fixture.c" with:
      """
      extern struct { int *p, i; } foo; /* W0425 */
      extern union { int *p, i; } bar; /* W0425 */
      typedef struct { int *p, i; } baz; /* W0425 */
      typedef union { int *p, i; } qux; /* W0425 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 30     |
      | W0118 | 2    | 29     |
      | W0551 | 2    | 8      |
      | W0551 | 4    | 9      |
      | W0425 | 1    | 25     |
      | W0425 | 2    | 24     |
      | W0425 | 3    | 26     |
      | W0425 | 4    | 25     |
