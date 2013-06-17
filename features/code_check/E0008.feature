Feature: E0008

  E0008 detects that a syntax error occured.

  Scenario: statements in initializer
    Given a target source named "fixture.c" with:
      """
      #ifdef FOOFOO
      void foo1(void);
      #endif

      void foo2(void); /* OK not E0008 */

      /**/\
      #define FOO 1
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 5    | 6      |
