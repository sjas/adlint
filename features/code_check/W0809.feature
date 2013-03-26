Feature: W0809

  W0809 detects that an identifier is declared but it already reserved by the
  library.

  Scenario: an identifier starts with `__'
    Given a target source named "fixture.c" with:
      """
      extern int __number; /* W0809 */
      extern int __NUMBER; /* W0809 */
      extern char __value; /* W0809 */
      extern char __VALUE; /* W0809 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W0118 | 3    | 13     |
      | W0118 | 4    | 13     |
      | W0809 | 1    | 12     |
      | W0809 | 2    | 12     |
      | W0809 | 3    | 13     |
      | W0809 | 4    | 13     |

  Scenario: an identifier starts with `_(capital letters)'
    Given a target source named "fixture.c" with:
      """
      extern int _NUMBER; /* W0809 */
      extern int _Number; /* W0809 */
      extern char _VALUE; /* W0809 */
      extern char _Value; /* W0809 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W0118 | 3    | 13     |
      | W0118 | 4    | 13     |
      | W0809 | 1    | 12     |
      | W0809 | 2    | 12     |
      | W0809 | 3    | 13     |
      | W0809 | 4    | 13     |

  Scenario: an identifier starts with `_' declared as function
    Given a target source named "fixture.c" with:
      """
      static void _func(void); /* W0809 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0809 | 1    | 13     |

  Scenario: an identifier starts with `_' declared as struct
    Given a target source named "fixture.c" with:
      """
      struct _foo { /* W0809 */
          int i;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0809 | 1    | 8      |

  Scenario: an identifier starts with `_' declared as typedef
    Given a target source named "fixture.c" with:
      """
      typedef void _type; /* W0809 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0809 | 1    | 14     |

  Scenario: an identifier starts with `_' declared as enum
    Given a target source named "fixture.c" with:
      """
      enum _color { Red, Green, Blue}; /* W0809 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0809 | 1    | 6      |

  Scenario: an identifier starts with `_' declared as enumerators
    Given a target source named "fixture.c" with:
      """
      enum color { _Red, _Green, _Blue}; /* W0809 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0809 | 1    | 14     |
      | W0809 | 1    | 20     |
      | W0809 | 1    | 28     |

  Scenario: an identifier starts with `_' declared as union
    Given a target source named "fixture.c" with:
      """
      union _uni { /* W0809 */
          int a;
          int b;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0551 | 1    | 7      |
      | W0809 | 1    | 7      |
