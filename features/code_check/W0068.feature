Feature: W0068

  W0068 detects use of the extended bit-access expression.

  Scenario: extended bit-access to the external `unsigned int' object
    Given a target source named "fixture.c" with:
      """
      #define FNAME(x) my_##x
      #define FCAST

      extern unsigned int a;

      float coshf(float x)
      {
          return (FNAME(cosh)(x, FCAST 1.0F) + a.1); /* W0068 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0118 | 4    | 21     |
      | W0117 | 6    | 7      |
      | W0109 | 8    | 13     |
      | W0104 | 6    | 19     |
      | W1073 | 8    | 24     |
      | W0068 | 8    | 43     |
      | W0628 | 6    | 7      |
