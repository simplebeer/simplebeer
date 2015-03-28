//= require moment

(function() {
  "use strict";

  App.newOrganizationSubscriptionPlanSelect = function(subscriptionPlans, subscriptionPlanId) {
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

    function setSelectedPlan(subscriptionPlan) {
      $('.subscription-plan').each(function() {
        $(this).removeClass('selected');
      });
      $('.subscription-plan[data-id="' + subscriptionPlan.id + '"]').addClass('selected');
      $('#organization_subscription_plan_id').val(subscriptionPlan.id);
    }

    $('.subscription-plan').click(function() {
      var element = $(this),
          selectedPlanId = element.data('id') + '',
          selectedPlan = findSubscriptionPlan(selectedPlanId);

      // Set the css classes and hidden field value
      setSelectedPlan(selectedPlan);

      return false;
    });

    if (subscriptionPlanId) {
      setSelectedPlan(findSubscriptionPlan(subscriptionPlanId));
    }
  };

})();
