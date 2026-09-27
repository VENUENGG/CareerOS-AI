package com.careeros.salary.engine;

import com.careeros.salary.entity.SalaryBenchmark;
import com.careeros.salary.entity.SalarySkillPremium;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

@Component
public class SalaryEstimationEngine {

    private static final BigDecimal MAX_SKILL_PREMIUM =
            BigDecimal.valueOf(30);

    public SalaryResult estimate(
            SalaryBenchmark benchmark,
            List<SalarySkillPremium> skillPremiums,
            int experienceYears
    ) {

        BigDecimal multiplier =
                calculateExperienceMultiplier(experienceYears);

        BigDecimal minimum =
                benchmark.getMinimumSalary()
                        .multiply(multiplier);

        BigDecimal expected =
                benchmark.getMedianSalary()
                        .multiply(multiplier);

        BigDecimal maximum =
                benchmark.getMaximumSalary()
                        .multiply(multiplier);

        BigDecimal totalSkillPremium =
                skillPremiums.stream()
                        .map(SalarySkillPremium::getPremiumPercentage)
                        .filter(premium -> premium != null)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

        totalSkillPremium =
                totalSkillPremium.min(MAX_SKILL_PREMIUM);

        BigDecimal skillMultiplier =
                BigDecimal.ONE.add(
                        totalSkillPremium.divide(
                                BigDecimal.valueOf(100),
                                6,
                                RoundingMode.HALF_UP
                        )
                );

        minimum = minimum.multiply(skillMultiplier);
        expected = expected.multiply(skillMultiplier);
        maximum = maximum.multiply(skillMultiplier);

        minimum = round(minimum);
        expected = round(expected);
        maximum = round(maximum);

        if (expected.compareTo(minimum) < 0) {
            expected = minimum;
        }

        if (maximum.compareTo(expected) < 0) {
            maximum = expected;
        }

        List<String> factors = new ArrayList<>();

        if (experienceYears > 0) {
            factors.add(
                    "Salary adjusted according to experience level."
            );
        }

        if (totalSkillPremium.compareTo(BigDecimal.ZERO) > 0) {
            factors.add(
                    "Selected skills contributed a positive market premium."
            );
        }

        factors.add(
                "Estimate is based on the configured CareerOS salary benchmark."
        );

        return new SalaryResult(
                minimum,
                expected,
                maximum,
                factors
        );
    }

    private BigDecimal calculateExperienceMultiplier(
            int experienceYears
    ) {

        if (experienceYears <= 0) {
            return BigDecimal.ONE;
        }

        if (experienceYears <= 2) {
            return BigDecimal.valueOf(1.05);
        }

        if (experienceYears <= 5) {
            return BigDecimal.valueOf(1.10);
        }

        if (experienceYears <= 8) {
            return BigDecimal.valueOf(1.15);
        }

        return BigDecimal.valueOf(1.20);
    }

    private BigDecimal round(BigDecimal value) {

        return value
                .setScale(0, RoundingMode.HALF_UP);
    }

    public record SalaryResult(
            BigDecimal minimumSalary,
            BigDecimal expectedSalary,
            BigDecimal maximumSalary,
            List<String> factors
    ) {
    }
}