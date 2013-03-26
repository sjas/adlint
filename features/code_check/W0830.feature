Feature: W0830

  W0830 detects that an extra comma appears after enumerator-list.

  Scenario: an extra comma after enumerator-list in the named enum-specifier
    Given a target source named "fixture.c" with:
      """
      enum Color { Red, Green, Blue, }; /* W0830 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0830 | 1    | 30     |

  Scenario: an extra comma after enumerator-list in the unnamed enum-specifier
    Given a target source named "fixture.c" with:
      """
      enum { Red, Green, Blue, }; /* W0830 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0830 | 1    | 24     |

  Scenario: no extra comma after enumerator-list in the named enum-specifier
    Given a target source named "fixture.c" with:
      """
      enum Color { Red, Green, Blue }; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: no extra comma after enumerator-list in the unnamed enum-specifier
    Given a target source named "fixture.c" with:
      """
      enum { Red, Green, Blue }; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: an extra comma after initialized enumerator-list in the named
            enum-specifier
    Given a target source named "fixture.c" with:
      """
      enum Color { Red = 1, Green = 2, Blue = 3, }; /* W0830 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0830 | 1    | 42     |

  Scenario: an extra comma after initialized enumerator-list in the unnamed
            enum-specifier
    Given a target source named "fixture.c" with:
      """
      enum { Red = 1, Green = 2, Blue = 3, }; /* W0830 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0830 | 1    | 36     |
