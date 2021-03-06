//
//  ValidationTestScenariosManager.swift
//
//  Copyright (c) 2019 Ogarkov Anton
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
import TestScenario

final class TestScenariosValidationContainer {
    fileprivate static let shared = TestScenariosValidationContainer()

    private(set) var reportedEventDescription = ""

    private func eventFiredReporterFunction(eventUniqueDescription: String) {
        self.reportedEventDescription = eventUniqueDescription
    }

    private func makeValidationScenarioInstance<Scenario>(scenarioClass: Scenario.Type) -> Scenario? where Scenario : TestScenario {
        let newScenarios = build(testScenarios: [scenarioClass], withReportEventClosure: { [weak self] eventDescription in
            self?.eventFiredReporterFunction(eventUniqueDescription: eventDescription)
            })

        return newScenarios.first as? Scenario
    }

    fileprivate func validateEventIsFired(eventToValidate: () -> ()) {
        eventToValidate()
        let lastFiredEventDescription = XCUIApplication().staticTexts["eventsReportingLabel"].label
        let eventToValidateDescription = self.reportedEventDescription
        XCTAssert(lastFiredEventDescription == eventToValidateDescription, "Last fired event mismatch with validated one. \n\n Last fired:\n\(lastFiredEventDescription) \n\n Validated event:\n\(eventToValidateDescription)")
    }

    fileprivate func activateScenario<Scenario>(scenario: Scenario.Type) -> Scenario where Scenario : TestScenario {
        guard let scenarioInstance = self.makeValidationScenarioInstance(scenarioClass: scenario) else {
            fatalError("Could not find scenario of type: \(scenario)")
        }
        XCUIApplication().tables.staticTexts[String(describing: scenario)].tap()
        return scenarioInstance
    }
}

// MARK: helper functions
public func ActivateScenario<Scenario>(scenario: Scenario.Type) -> Scenario where Scenario : TestScenario {
    return TestScenariosValidationContainer.shared.activateScenario(scenario: scenario)
}

public func DeactivateScenario() {
    XCUIApplication().buttons["closeScenarioButton"].tap()
}

public func ValidateScenarioEventIsFired(eventToValidate: @autoclosure () -> ()) {
    TestScenariosValidationContainer.shared.validateEventIsFired(eventToValidate: eventToValidate)
}

