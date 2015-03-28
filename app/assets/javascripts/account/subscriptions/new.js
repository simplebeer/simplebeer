(function() {
  "use strict";

  App.subscriptionPlanSelect = function(currentSubscription, subscriptionPlans) {
    var currentPlanId = null;

    function findSubscriptionPlan(planId) {
      var selectedPlan;

      $.each(subscriptionPlans, function() {
        if (this.id + '' === planId + '') {
          selectedPlan = this;
        }
      });

      return selectedPlan;
    }

    function setChangeMessage(newPlan) {
      if (newPlan.id + '' === currentPlanId) {
        $('.message').html(noChangeMessage);
      } else {
        $('.message').html(newPlan.upgradeMessage);
      }
    }

    function setSelectedPlan(subscriptionPlan) {
      $('.subscription-plan').each(function() {
        $(this).removeClass('selected');
      });
      $('.subscription-plan[data-id="' + subscriptionPlan.id + '"]').addClass('selected');
      $('#subscription_subscription_plan_id').val(subscriptionPlan.id);
    }

    function setSubmitButtonDisabled(disabled) {
      if (disabled) {
        $('input[type="submit"]').prop('disabled', 'disabled');
      } else {
        $('input[type="submit"]').prop('disabled', '');
      }
    }

    if (currentSubscription) {
      var currentPlan           = currentSubscription.plan,
          noChangeMessage       = $('.message').html();

      currentPlanId = currentPlan.id + '';

      // Setup elements with current plan selected
      setSelectedPlan(currentPlan);
      $('.subscription-plan[data-id="' + currentPlan.id + '"]').addClass('current');
    } else {
      $('.message').html('You do not have an existing subscription.<br>Select a plan to sign up for a new subscription.');
    }
    setSubmitButtonDisabled(true);

    $('.subscription-plan').click(function() {
      var element = $(this),
          selectedPlanId = element.data('id') + '',
          selectedPlan = findSubscriptionPlan(selectedPlanId);

      // Set the css classes and hidden field value
      setSelectedPlan(selectedPlan);

      // Enable/disable the submit button
      setSubmitButtonDisabled(selectedPlanId === currentPlanId);

      // Set the message for upgrading / downgrading
      setChangeMessage(selectedPlan);

      return false;
    });
  };

})();
