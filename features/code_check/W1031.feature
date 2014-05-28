Feature: W1031

  W1031 detects that two or more object declarations have inconsistent
  storage-class-specifiers.

  Scenario: function declaration with `static' and function definition without
            storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      static int foo(long);

      int foo(long l) { /* OK */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1075 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W0629 | 3    | 5      |
      | W0628 | 3    | 5      |

  Scenario: function declaration with `extern' and function definition without
            storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      extern int foo(long);

      int foo(long l) { /* OK */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0104 | 3    | 14     |
      | W0628 | 3    | 5      |

  Scenario: function declaration without storage-class-specifier and function
            definition without storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      int foo(long);

      int foo(long l) { /* OK */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 5      |
      | W0104 | 3    | 14     |
      | W0628 | 3    | 5      |

  Scenario: function declaration without storage-class-specifier and function
            definition with `static'
    Given a target source named "fixture.c" with:
      """
      int foo(long);

      static int foo(long l) { /* W1031 */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 5      |
      | W1031 | 3    | 12     |
      | W0104 | 3    | 21     |
      | W0628 | 3    | 12     |

  Scenario: function declaration without storage-class-specifier and function
            definition with `extern'
    Given a target source named "fixture.c" with:
      """
      int foo(long);

      extern int foo(long l) { /* OK */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 5      |
      | W0104 | 3    | 21     |
      | W0628 | 3    | 12     |

  Scenario: function declaration with `static' and function definition with
            `extern'
    Given a target source named "fixture.c" with:
      """
      static int foo(long);

      extern int foo(long l) { /* W1031 */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1031 | 3    | 12     |
      | W1075 | 3    | 12     |
      | W0104 | 3    | 21     |
      | W0629 | 3    | 12     |
      | W0628 | 3    | 12     |

  Scenario: function declaration with `extern' and function definition with
            `static'
    Given a target source named "fixture.c" with:
      """
      extern int foo(long);

      static int foo(long l) { /* W1031 */
          return (int) l;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1031 | 3    | 12     |
      | W0104 | 3    | 21     |
      | W0628 | 3    | 12     |

  Scenario: variable declaration with `extern' and variable definition without
            storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      extern int i;
      int i = 0; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |

  Scenario: variable definition without storage-class-specifier and variable
            declaration with `extern'
    Given a target source named "fixture.c" with:
      """
      int i;
      extern int i; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0118 | 2    | 12     |

  Scenario: variable definition with `static' and variable definition with
            `extern'
    Given a target source named "fixture.c" with:
      """
      static int i;
      extern int i = 0; /* W1031 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1031 | 2    | 12     |
      | W1075 | 2    | 12     |

  Scenario: variable declaration with `extern' and variable definition with
            `static'
    Given a target source named "fixture.c" with:
      """
      extern int i;
      static int i = 0; /* W1031 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1031 | 2    | 12     |

  Scenario: function definition with `static' and function declaration without
            storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      static int foo(long l) {
          return (int) l;
      }

      int foo(long); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1075 | 5    | 5      |
      | W0629 | 1    | 12     |
      | W0543 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: function definition with `extern' and function declaration without
            storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      extern int foo(long l) {
          return (int) l;
      }

      int foo(long); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W0118 | 5    | 5      |
      | W0543 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: function definition without storage-class-specifier and function
            declaration without storage-class-specifier
    Given a target source named "fixture.c" with:
      """
      int foo(long l) {
          return (int) l;
      }

      int foo(long); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 14     |
      | W0118 | 5    | 5      |
      | W0543 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: function definition without storage-class-specifier and function
            declaration with `static'
    Given a target source named "fixture.c" with:
      """
      int foo(long l) {
          return (int) l;
      }

      static int foo(long); /* W1031 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 14     |
      | W0118 | 5    | 12     |
      | W1031 | 5    | 12     |
      | W0543 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: function definition without storage-class-specifier and function
            declaration with `extern'
    Given a target source named "fixture.c" with:
      """
      int foo(long l) {
          return (int) l;
      }

      extern int foo(long); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 14     |
      | W0118 | 5    | 12     |
      | W0543 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: function definition with `static' and function declaration with
            `extern'
    Given a target source named "fixture.c" with:
      """
      static int foo(long l) {
          return (int) l;
      }

      extern int foo(long l); /* W1031 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W1031 | 5    | 12     |
      | W1075 | 5    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: function definition with `extern' and function declaration with
            `static'
    Given a target source named "fixture.c" with:
      """
      extern int foo(long l) {
          return (int) l;
      }

      static int foo(long); /* W1031 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0104 | 1    | 21     |
      | W0118 | 5    | 12     |
      | W1031 | 5    | 12     |
      | W0543 | 1    | 12     |
      | W0628 | 1    | 12     |
