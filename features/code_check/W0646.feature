Feature: W0646

  W0646 detects that a string-literal of narrow characters and a string-literal
  of wide characters are neighboring.

  Scenario: a string-literal of narrow characters followed by one of wide
            characters
    Given a target source named "fixture.c" with:
      """
      static const char *str = "foo" L"bar"; /* W0646 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0646 | 1    | 32     |
      | W0947 | 1    | 26     |

  Scenario: a string-literal of narrow characters followed by a compatible
            string-literal
    Given a target source named "fixture.c" with:
      """
      static const char *str = "foo" "bar"; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0947 | 1    | 26     |

  Scenario: a string-literal of wide characters followed by one of narrow
            characters
    Given a target source named "fixture.c" with:
      """
      static const char *str = L"foo" "bar"; /* W0646 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0646 | 1    | 33     |
      | W9003 | 1    | 26     |
      | W0626 | 1    | 26     |
      | W0947 | 1    | 26     |

  Scenario: a string-literal of wide characters followed by a compatible
            string-literal
    Given a target source named "fixture.c" with:
      """
      static const char *str = L"foo" L"bar"; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W9003 | 1    | 26     |
      | W0626 | 1    | 26     |
      | W0947 | 1    | 26     |

  Scenario: a string-literal of narrow characters followed by one of wide
            characters those are replaced by macros
    Given a target source named "fixture.c" with:
      """
      #define STR1 "foo"
      #define STR2 L"bar"

      static const char *str = STR1 STR2; /* W0646 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0646 | 4    | 31     |

  Scenario: a string-literal of narrow characters followed by a compatible
            string-literal those are replaced by macros
    Given a target source named "fixture.c" with:
      """
      #define STR1 "foo"
      #define STR2 "bar"

      static const char *str = STR1 STR2; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: a string-literal of wide characters followed by one of narrow
            characters those are replaced by macros
    Given a target source named "fixture.c" with:
      """
      #define STR1 L"foo"
      #define STR2 "bar"

      static const char *str = STR1 STR2; /* W0646 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0646 | 4    | 31     |
      | W9003 | 4    | 26     |
      | W0626 | 4    | 26     |

  Scenario: a string-literal of wide characters followed by a compatible
            string-literal those are replaced by macros
    Given a target source named "fixture.c" with:
      """
      #define STR1 L"foo"
      #define STR2 L"bar"

      static const char *str = STR1 STR2; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W9003 | 4    | 26     |
      | W0626 | 4    | 26     |
