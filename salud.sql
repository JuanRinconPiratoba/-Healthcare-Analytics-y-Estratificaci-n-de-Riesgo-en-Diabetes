CREATE TABLE diabetes_patients (
    gender VARCHAR(20),
    age NUMERIC(5,2),
    hypertension INTEGER,
    heart_disease INTEGER,
    smoking_history VARCHAR(20),
    bmi NUMERIC(6,2),
    hba1c_level NUMERIC(4,1),
    blood_glucose_level INTEGER,
    diabetes INTEGER
);

-- conteo
SELECT COUNT(*)
FROM diabetes_patients;

-- valores nulos 
SELECT
    COUNT(*) AS duplicated_rows
FROM (
    SELECT
        gender,
        age,
        hypertension,
        heart_disease,
        smoking_history,
        bmi,
        hba1c_level,
        blood_glucose_level,
        diabetes,
        COUNT(*)
    FROM diabetes_patients
    GROUP BY
        gender,
        age,
        hypertension,
        heart_disease,
        smoking_history,
        bmi,
        hba1c_level,
        blood_glucose_level,
        diabetes
    HAVING COUNT(*) > 1
) t;

--valores nulos
SELECT
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_nulls,
    SUM(CASE WHEN hypertension IS NULL THEN 1 ELSE 0 END) AS hypertension_nulls,
    SUM(CASE WHEN heart_disease IS NULL THEN 1 ELSE 0 END) AS heart_disease_nulls,
    SUM(CASE WHEN smoking_history IS NULL THEN 1 ELSE 0 END) AS smoking_history_nulls,
    SUM(CASE WHEN bmi IS NULL THEN 1 ELSE 0 END) AS bmi_nulls,
    SUM(CASE WHEN hba1c_level IS NULL THEN 1 ELSE 0 END) AS hba1c_nulls,
    SUM(CASE WHEN blood_glucose_level IS NULL THEN 1 ELSE 0 END) AS glucose_nulls,
    SUM(CASE WHEN diabetes IS NULL THEN 1 ELSE 0 END) AS diabetes_nulls
FROM diabetes_patients;

-----------------RANGOS--------------------
SELECT
    MIN(age),
    MAX(age)
FROM diabetes_patients;

SELECT
    MIN(bmi),
    MAX(bmi)
FROM diabetes_patients;

SELECT
    MIN(hba1c_level),
    MAX(hba1c_level)
FROM diabetes_patients;

SELECT
    MIN(blood_glucose_level),
    MAX(blood_glucose_level)
FROM diabetes_patients;

--PREVALECIA DE DIABETES
SELECT
    diabetes,
    COUNT(*) AS patients,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM diabetes_patients
GROUP BY diabetes
ORDER BY diabetes;

--DISTRIBUCIÓN POR SEXO
SELECT
    gender,
    COUNT(*) AS patients,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM diabetes_patients
GROUP BY gender
ORDER BY patients DESC;

--DIABETES POR SEXO 
SELECT
    gender,
    COUNT(*) AS total_patients,
    SUM(diabetes) AS diabetes_cases,
    ROUND(
        SUM(diabetes) * 100.0 /
        COUNT(*),
        2
    ) AS prevalence_pct
FROM diabetes_patients
GROUP BY gender
ORDER BY prevalence_pct DESC;

--Hipertensión 
SELECT
    hypertension,
    COUNT(*) AS total_patients,
    SUM(diabetes) AS diabetes_cases,
    ROUND(
        SUM(diabetes) * 100.0 /
        COUNT(*),
        2
    ) AS prevalence_pct
FROM diabetes_patients
GROUP BY hypertension
ORDER BY hypertension;

-- Enfermedad Cardiaca
SELECT
    heart_disease,
    COUNT(*) AS total_patients,
    SUM(diabetes) AS diabetes_cases,
    ROUND(
        SUM(diabetes) * 100.0 /
        COUNT(*),
        2
    ) AS prevalence_pct
FROM diabetes_patients
GROUP BY heart_disease
ORDER BY heart_disease;

-- Historial tabaquismo
SELECT
    smoking_history,
    COUNT(*) AS total_patients,
    SUM(diabetes) AS diabetes_cases,
    ROUND(
        SUM(diabetes) * 100.0 /
        COUNT(*),
        2
    ) AS prevalence_pct
FROM diabetes_patients
GROUP BY smoking_history
ORDER BY prevalence_pct DESC;

--CONSULTAS 
--EDAD
SELECT
CASE
    WHEN age < 18 THEN '0-17'
    WHEN age < 40 THEN '18-39'
    WHEN age < 60 THEN '40-59'
    ELSE '60+'
END AS age_group,
COUNT(*) AS total_patients,
SUM(diabetes) AS diabetes_cases,
ROUND(
    SUM(diabetes) * 100.0 / COUNT(*),
    2
) AS prevalence_pct
FROM diabetes_patients
GROUP BY age_group
ORDER BY age_group;

--BMI
SELECT
CASE
    WHEN bmi < 18.5 THEN 'Underweight'
    WHEN bmi < 25 THEN 'Normal'
    WHEN bmi < 30 THEN 'Overweight'
    ELSE 'Obesity'
END AS bmi_category,
COUNT(*) AS total_patients,
SUM(diabetes) AS diabetes_cases,
ROUND(
    SUM(diabetes) * 100.0 / COUNT(*),
    2
) AS prevalence_pct
FROM diabetes_patients
GROUP BY bmi_category
ORDER BY prevalence_pct;

--HbA1c
SELECT
CASE
    WHEN hba1c_level < 5.7 THEN 'Normal'
    WHEN hba1c_level < 6.5 THEN 'Prediabetes'
    ELSE 'Diabetes Range'
END AS hba1c_category,
COUNT(*) AS total_patients,
SUM(diabetes) AS diabetes_cases,
ROUND(
    SUM(diabetes) * 100.0 / COUNT(*),
    2
) AS prevalence_pct
FROM diabetes_patients
GROUP BY hba1c_category
ORDER BY prevalence_pct;

-- Blood glucose 
SELECT
CASE
    WHEN blood_glucose_level < 100 THEN 'Normal'
    WHEN blood_glucose_level < 126 THEN 'Prediabetes'
    ELSE 'High Glucose'
END AS glucose_category,
COUNT(*) AS total_patients,
SUM(diabetes) AS diabetes_cases,
ROUND(
    SUM(diabetes) * 100.0 / COUNT(*),
    2
) AS prevalence_pct
FROM diabetes_patients
GROUP BY glucose_category
ORDER BY prevalence_pct;

--Edad + Hipertensión 
SELECT
CASE
    WHEN age < 18 THEN '0-17'
    WHEN age < 40 THEN '18-39'
    WHEN age < 60 THEN '40-59'
    ELSE '60+'
END AS age_group,
hypertension,
COUNT(*) AS total_patients,
SUM(diabetes) AS diabetes_cases,
ROUND(
    SUM(diabetes) * 100.0 / COUNT(*),
    2
) AS prevalence_pct
FROM diabetes_patients
GROUP BY age_group, hypertension
ORDER BY age_group, hypertension;

---------------CREACIÓN TABLA RISK SCORE-------------------------------
SELECT
    *,
    
    (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
    (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
    (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
    (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
    
    AS risk_score

FROM diabetes_patients;

--Categoria de riesgo
SELECT
    *,
    
    (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
    (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
    (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
    (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
    
    AS risk_score,

    CASE
        WHEN
            (
                (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
                (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
                (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
                (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
                (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
                (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
            ) <= 1
        THEN 'Low Risk'

        WHEN
            (
                (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
                (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
                (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
                (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
                (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
                (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
            ) <= 3
        THEN 'Moderate Risk'

        WHEN
            (
                (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
                (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
                (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
                (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
                (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
                (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
            ) <= 5
        THEN 'High Risk'

        ELSE 'Very High Risk'
    END AS risk_category

FROM diabetes_patients;

---Consultas de interés 
WITH risk_table AS (
    SELECT
        diabetes,

        (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
        (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
        (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
        (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
        (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
        AS risk_score

    FROM diabetes_patients
)

SELECT
    risk_score,
    COUNT(*) AS total_patients,
    SUM(diabetes) AS diabetes_cases,
    ROUND(
        SUM(diabetes) * 100.0 / COUNT(*),
        2
    ) AS prevalence_pct
FROM risk_table
GROUP BY risk_score
ORDER BY risk_score;

-- Visualización
CREATE VIEW vw_patient_risk AS

SELECT
    *,
    
    (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
    (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
    (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
    (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
    (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
    AS risk_score,

    CASE
        WHEN (
            (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
            (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
            (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
            (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
        ) <= 1 THEN 'Low Risk'

        WHEN (
            (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
            (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
            (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
            (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
        ) <= 3 THEN 'Moderate Risk'

        WHEN (
            (CASE WHEN age >= 60 THEN 1 ELSE 0 END) +
            (CASE WHEN hypertension = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN heart_disease = 1 THEN 1 ELSE 0 END) +
            (CASE WHEN bmi >= 30 THEN 1 ELSE 0 END) +
            (CASE WHEN hba1c_level >= 6.5 THEN 1 ELSE 0 END) +
            (CASE WHEN blood_glucose_level >= 126 THEN 1 ELSE 0 END)
        ) <= 5 THEN 'High Risk'

        ELSE 'Very High Risk'
    END AS risk_category

FROM diabetes_patients;

--Distribución de pacientes por categoría de riesgo
SELECT
    risk_category,
    COUNT(*) AS patients
FROM vw_patient_risk
GROUP BY risk_category
ORDER BY patients DESC; 

-- Prevalencia por categoría de riesgo
SELECT
    risk_category,
    COUNT(*) AS total_patients,
    SUM(diabetes) AS diabetes_cases,
    ROUND(
        SUM(diabetes) * 100.0 /
        COUNT(*),
        2
    ) AS prevalence_pct
FROM vw_patient_risk
GROUP BY risk_category
ORDER BY prevalence_pct;
