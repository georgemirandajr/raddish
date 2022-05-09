require(rstudioapi)
setupVacancyPath = function() {
  rstudioapi::insertText(
    "vacancy_path = 'S:/WPTRA/Recruitment & Workforce Reduction/Vacancy Reports/New Model (position control summary)/'"
  )
}
