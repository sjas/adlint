Feature: E0016

  E0016 detects that a block comment is not terminated in the translation unit.

  Scenario: `/*' sequence in a string-literal
    Given a target source named "fixture.c" with:
      """
      #define FOO

      extern void bar(const char *);

      void baz(void)
      {
      #ifdef FOO
          bar("1 /*\n");
      #else
          bar("2 /*\n");
      #endif
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W0117 | 5    | 6      |
      | W0947 | 8    | 9      |
      | W0628 | 5    | 6      |

  Scenario: `/*' sequence in a string-literal
    Given a target source named "fixture.c" with:
      """
      extern void bar(const char *);

      void baz(void)
      {
      #ifdef FOO
          bar("1 /*\n");
      #else
          bar("2 /*\n");
      #endif
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0947 | 8    | 9      |
      | W0628 | 3    | 6      |
