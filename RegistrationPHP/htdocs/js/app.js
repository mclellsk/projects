var app = angular.module("appName",[]);

app.directive('pwCheck', [function () {
	return {
	  require: 'ngModel',
	  link: function (scope, element, attrs, controller) {
		var firstPassword = '#' + attrs.pwCheck;
		$(element).add(firstPassword).on('keyup', function () {
			scope.$apply(function () {
				var v = element.val()===$(firstPassword).val();
				controller.$setValidity('pwmatch', v);
			});
		});
	  }
	}
}]);