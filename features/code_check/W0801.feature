Feature: W0801

  W0801 detects that there is no named member in this struct or union.

  Scenario: no member exists in the struct
    Given a target source named "fixture.c" with:
      """
      struct foo { /* W0801 */
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0801 | 1    | 8      |

  Scenario: no named member exists in the struct
    Given a target source named "fixture.c" with:
      """
      struct bar { /* W0801 */
          int;
          int :1;
          long;
          double;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0040 | 1    | 8      |
      | W0801 | 1    | 8      |

  Scenario: named member exists in the struct
    Given a target source named "fixture.c" with:
      """
      struct baz { /* OK */
          int i;
          long l;
          double d;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: no member exists in the union
    Given a target source named "fixture.c" with:
      """
      union foo { /* W0801 */
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0551 | 1    | 7      |
      | W0801 | 1    | 7      |

  Scenario: no named member exists in the union
    Given a target source named "fixture.c" with:
      """
      union bar { /* W0801 */
          int;
          int :1;
          long;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0040 | 1    | 7      |
      | W0551 | 1    | 7      |
      | W0801 | 1    | 7      |

  Scenario: named member exists in the union
    Given a target source named "fixture.c" with:
      """
      union baz { /* OK */
          int i;
          long l;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0551 | 1    | 7      |
