Feature: W1050

  W1050 detects that an explicit conversion to signed integer must cause
  overflow.

  Scenario: conversion from `int' to `signed char'
    Given a target source named "fixture.c" with:
      """
      static void foo(const int i)
      {
          if (i > 127) {
              const signed char c = (signed char) i; /* W1050 */
          }
          if (i < -128) {
              const signed char c = (signed char) i; /* W1050 */
          }

          if (i > 100) {
              const signed char c = (signed char) i; /* OK but W1049 */
          }
          if (i < -100) {
              const signed char c = (signed char) i; /* OK but W1049 */
          }

          if (i > -129 && i < 128) {
              const signed char c = (signed char) i; /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W1050 | 4    | 31     |
      | C1000 |      |        |
      | C1006 | 1    | 27     |
      | W1050 | 7    | 31     |
      | C1000 |      |        |
      | C1006 | 1    | 27     |
      | W1049 | 11   | 31     |
      | C1000 |      |        |
      | C1006 | 1    | 27     |
      | W1049 | 14   | 31     |
      | C1000 |      |        |
      | C1006 | 1    | 27     |
      | W0629 | 1    | 13     |
      | W0489 | 17   | 9      |
      | W0490 | 17   | 9      |
      | W0499 | 17   | 9      |
      | W0502 | 17   | 9      |
      | W0628 | 1    | 13     |
