package main

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/jennxsierra/lab4-db-crud-implementation/internal/data"
	"github.com/jennxsierra/lab4-db-crud-implementation/internal/validator"
	"github.com/julienschmidt/httprouter"
)

// Helper to extract :patient_no param
func (a *applicationDependencies) readPatientNoParam(r *http.Request) string {
	params := httprouter.ParamsFromContext(r.Context())
	return params.ByName("patient_no")
}

// POST /v1/patients -- create new patient
func (a *applicationDependencies) createPatientHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		PatientNo   string `json:"patient_no"`
		FirstName   string `json:"first_name"`
		LastName    string `json:"last_name"`
		DateOfBirth string `json:"date_of_birth"`
		Gender      string `json:"gender"`
		SSN         string `json:"ssn"`
	}

	err := a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	patient := &data.Patient{
		PatientNo:   input.PatientNo,
		FirstName:   input.FirstName,
		LastName:    input.LastName,
		DateOfBirth: input.DateOfBirth,
		Gender:      input.Gender,
		SSN:         input.SSN,
	}

	v := validator.New()
	data.ValidatePatient(v, patient)
	if !v.IsEmpty() {
		a.errorResponseJSON(w, r, http.StatusUnprocessableEntity, v.Errors)
		return
	}

	err = a.models.Patient.Insert(patient)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	headers := make(http.Header)
	headers.Set("Location", fmt.Sprintf("/v1/patients/%s", patient.PatientNo))

	err = a.writeJSON(w, http.StatusCreated, envelope{"patient": patient}, headers)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// GET /v1/patients/:patient_no -- show patient by number
func (a *applicationDependencies) showPatientHandler(w http.ResponseWriter, r *http.Request) {
	patientNo := a.readPatientNoParam(r)

	patient, err := a.models.Patient.Get(patientNo)
	if err != nil {
		if errors.Is(err, errors.New("record not found")) {
			a.notFoundResponse(w, r)
		} else {
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"patient": patient}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// GET /v1/patients?name=... -- list all (optionally filtered by name)
func (a *applicationDependencies) listPatientsHandler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")

	patients, err := a.models.Patient.GetAll(name)
	if err != nil {
		a.serverErrorResponse(w, r, err)
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"patients": patients}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// PUT/PATCH /v1/patients/:patient_no -- update (full or partial)
func (a *applicationDependencies) updatePatientHandler(w http.ResponseWriter, r *http.Request) {
	patientNo := a.readPatientNoParam(r)

	patient, err := a.models.Patient.Get(patientNo)
	if err != nil {
		if errors.Is(err, errors.New("record not found")) {
			a.notFoundResponse(w, r)
		} else {
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	var input struct {
		FirstName   *string `json:"first_name"`
		LastName    *string `json:"last_name"`
		DateOfBirth *string `json:"date_of_birth"`
		Gender      *string `json:"gender"`
		SSN         *string `json:"ssn"`
	}

	err = a.readJSON(w, r, &input)
	if err != nil {
		a.badRequestResponse(w, r, err)
		return
	}

	// Only update fields present in JSON (for PATCH semantics)
	if input.FirstName != nil {
		patient.FirstName = *input.FirstName
	}
	if input.LastName != nil {
		patient.LastName = *input.LastName
	}
	if input.DateOfBirth != nil {
		patient.DateOfBirth = *input.DateOfBirth
	}
	if input.Gender != nil {
		patient.Gender = *input.Gender
	}
	if input.SSN != nil {
		patient.SSN = *input.SSN
	}

	v := validator.New()
	data.ValidatePatient(v, patient)
	if !v.IsEmpty() {
		a.errorResponseJSON(w, r, http.StatusUnprocessableEntity, v.Errors)
		return
	}

	err = a.models.Patient.Update(patient)
	if err != nil {
		if errors.Is(err, errors.New("record not found")) {
			a.notFoundResponse(w, r)
		} else {
			a.serverErrorResponse(w, r, err)
		}
		return
	}

	err = a.writeJSON(w, http.StatusOK, envelope{"patient": patient}, nil)
	if err != nil {
		a.serverErrorResponse(w, r, err)
	}
}

// DELETE /v1/patients/:patient_no
func (a *applicationDependencies) deletePatientHandler(w http.ResponseWriter, r *http.Request) {
	patientNo := a.readPatientNoParam(r)
	err := a.models.Patient.Delete(patientNo)
	if err != nil {
		if errors.Is(err, errors.New("record not found")) {
			a.notFoundResponse(w, r)
		} else {
			a.serverErrorResponse(w, r, err)
		}
		return
	}
	a.writeJSON(w, http.StatusOK, envelope{"message": "patient successfully deleted"}, nil)
}
