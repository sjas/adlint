Feature: W1046

  W1046 detects that a space or tab character is found after newline escaping
  `\' character.

  Scenario: illformed newline escape in #define directive
    Given a target source named "fixture.c" with:
      """
      #define FOO(a, b)   /* OK */    \
          (               /* W1046 */ \ 
              (a) + (b)   /* W1046 */ \	
          )
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1046 | 2    | 33     |
      | W1046 | 3    | 33     |
      | W0442 | 1    | 1      |
      | W0443 | 1    | 1      |

  Scenario: illformed newline escape in declaration
    Given a target source named "fixture.c" with:
      """
      const char *str = "foo"     /* OK */    \
                        "bar"     /* W1046 */ \  
                        "baz"     /* W1046 */ \	 
                        "qux";
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1046 | 2    | 41     |
      | W1046 | 3    | 41     |
      | W0117 | 1    | 13     |
      | W0947 | 1    | 19     |

  Scenario: illformed newline escape in expression
    Given a target source named "fixture.c" with:
      """
      static void bar(const char *str);

      void foo(void)
      {
          bar("foo"     /* OK */    \
              "bar"     /* W1046 */ \  
              "baz"     /* W1046 */ \	 
              "qux");
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1046 | 6    | 31     |
      | W1046 | 7    | 31     |
      | W0117 | 3    | 6      |
      | W0947 | 5    | 9      |
      | W0628 | 3    | 6      |
