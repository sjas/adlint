Feature: W0542

  W0542 detects that some of parameters have an identifier.

  Scenario: hard to parse
    Given a target source named "fixture.c" with:
      """
      typedef unsigned int VALUE;
      typedef void *ANYARGS;

      VALUE foo(VALUE(*p1)(VALUE),VALUE,VALUE(*p2)(ANYARGS),VALUE); /* W0542 */
      VALUE bar(VALUE(*)(VALUE),VALUE,VALUE(*)(ANYARGS),VALUE);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 7      |
      | W0625 | 1    | 22     |
      | W0118 | 5    | 7      |
      | W0542 | 4    | 7      |
