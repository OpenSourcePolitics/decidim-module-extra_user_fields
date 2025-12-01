$(document).ready(function() {
    const accountInput = $('#user_date_of_birth_date');
    const registrationInput = $('#registration_user_date_of_birth_date')
    const button = $('.datepicker__calendar-button');
    if (accountInput && !accountInput.attr('aria-label')){
        accountInput.attr('aria-label', "user date of birth")
    }
    if (registrationInput && !registrationInput.attr('aria-label')){
        registrationInput.attr('aria-label', "user date of birth")
    }
    if (button && !button.attr('aria-label')){
        button.attr('aria-label', "datepicker button")
    }
});
