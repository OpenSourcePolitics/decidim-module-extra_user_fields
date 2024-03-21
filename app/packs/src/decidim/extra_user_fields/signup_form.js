$(document).ready(function() {
    const underageCheckbox = $('#registration_underage_checkbox');
    const statutoryRepresentativeEmailField = $('#statutory_representative_email_field');
    const dateOfBirthField = $('#registration_user_date_of_birth');
    const underageFieldSet = $('#underage_fieldset');
    let underageLimit = 30;

    if (underageCheckbox.length && statutoryRepresentativeEmailField.length) {
        underageCheckbox.on('change', function() {
            if (underageCheckbox.prop('checked')) {
                statutoryRepresentativeEmailField.removeClass('hidden');
                console.log("Underage checkbox checked.");
            } else {
                statutoryRepresentativeEmailField.addClass('hidden');
                console.log("Underage checkbox unchecked.");
            }
        });
    }

    $.ajax({
        url: '/extra_user_fields/underage_limit', // Updated to match the new route
        type: 'GET',
        success: function(data) {
            console.log("Underage limit fetched successfully.");
            console.log(data);
            underageLimit = data.underage_limit;
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.log(jqXHR.responseText);
            console.error("Failed to fetch underage limit:", textStatus, errorThrown);
        }
    });

    if (dateOfBirthField.length && underageFieldSet.length) {
        dateOfBirthField.on('change', function() {
            const dobValue = dateOfBirthField.val();
            const dobParts = dobValue.split('/');
            const dobDate = Date.parse(`${dobParts[1]}-${dobParts[0]}-${dobParts[2]}`);

            const currentDate = Date.now();
            const ageInMilliseconds = currentDate - dobDate;
            const age = Math.abs(new Date(ageInMilliseconds).getUTCFullYear() - 1970);

            console.log(underageLimit);

            if (age < underageLimit) {
                underageFieldSet.removeClass('hidden');
                underageCheckbox.prop('checked', true);
                statutoryRepresentativeEmailField.removeClass('hidden');
            } else {
                underageFieldSet.addClass('hidden');
                underageCheckbox.prop('checked', false);
                statutoryRepresentativeEmailField.addClass('hidden');
            }
        });
    }
});
