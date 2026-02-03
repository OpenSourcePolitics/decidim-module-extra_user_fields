// Wait for Web Components to be fully loaded before modifying attributes
function initializeDatepickerAccessibility() {
    if (window.customElements && window.customElements.whenDefined) {
        Promise.all([
            customElements.whenDefined('wc-datepicker'),
            new Promise(resolve => setTimeout(resolve, 100))
        ]).then(() => {
            applyAccessibilityAttributes();
        }).catch((error) => {
            console.warn('Datepicker component not found, applying attributes anyway:', error);
            // Fallback to immediate application
            setTimeout(applyAccessibilityAttributes, 500);
        });
    } else {
        setTimeout(applyAccessibilityAttributes, 500);
    }
}

function applyAccessibilityAttributes() {
    const accountInput = document.getElementById('user_date_of_birth_date');
    const registrationInput = document.getElementById('registration_user_date_of_birth_date');
    const button = document.querySelector('.datepicker__calendar-button');

    if (accountInput && !accountInput.getAttribute('aria-label')) {
        accountInput.setAttribute('aria-label', 'user date of birth');
        console.log('Applied aria-label to account input');
    }

    if (registrationInput && !registrationInput.getAttribute('aria-label')) {
        registrationInput.setAttribute('aria-label', 'user date of birth');
        console.log('Applied aria-label to registration input');
    }

    if (button && !button.getAttribute('aria-label')) {
        button.setAttribute('aria-label', 'datepicker button');
        console.log('Applied aria-label to datepicker button');
    }
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeDatepickerAccessibility);
} else {
    initializeDatepickerAccessibility();
}

document.addEventListener('turbo:load', initializeDatepickerAccessibility);
document.addEventListener('turbolinks:load', initializeDatepickerAccessibility);
