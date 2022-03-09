sap.ui.define([                                                                                                                                                                                                                                                
	"sap/ui/core/UIComponent",                                                                                                                                                                                                                                    
	"sap/ui/Device",                                                                                                                                                                                                                                              
	"UpdateCheque/model/models"                                                                                                                                                                                                                                   
], function(UIComponent, Device, models) {                                                                                                                                                                                                                     
	"use strict";                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                               
	return UIComponent.extend("UpdateCheque.Component", {                                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
		metadata: {                                                                                                                                                                                                                                                  
			manifest: "json"                                                                                                                                                                                                                                            
		},                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                               
		/**                                                                                                                                                                                                                                                          
		 * The component is initialized by UI5 automatically during the startup of the app and calls the init method once.                                                                                                                                           
		 * @public                                                                                                                                                                                                                                                   
		 * @override                                                                                                                                                                                                                                                 
		 */                                                                                                                                                                                                                                                          
		init: function() {                                                                                                                                                                                                                                           
			// call the base component's init function                                                                                                                                                                                                                  
			UIComponent.prototype.init.apply(this, arguments);                                                                                                                                                                                                          
                                                                                                                                                                                                                                                               
			// set the device model                                                                                                                                                                                                                                     
			this.setModel(models.createDeviceModel(), "device");                                                                                                                                                                                                        
                                                                                                                                                                                                                                                               
			var oModel = new sap.ui.model.json.JSONModel();                                                                                                                                                                                                             
			this.setModel(oModel, "foregroundData");                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                               
			// Initialize the router&nbsp;                                                                                                                                                                                                                              
			this.getRouter().initialize();                                                                                                                                                                                                                              
			this._handleRoutingTargetsDisplay();                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                               
		},                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                               
		_handleRoutingTargetsDisplay: function() {                                                                                                                                                                                                                   
			this.getRouter().getTargets().attachDisplay(function(oEvent) {                                                                                                                                                                                              
				var oTargetControl = oEvent.getParameter("control");                                                                                                                                                                                                       
				var sTargetViewId = oEvent.getParameter("view").getId();                                                                                                                                                                                                   
				var sTransition = oEvent.getParameter("config").transition;                                                                                                                                                                                                
                                                                                                                                                                                                                                                               
				// Router has added the route to the control. Trigger a navigation                                                                                                                                                                                         
				oTargetControl.to(sTargetViewId, sTransition);                                                                                                                                                                                                             
			});                                                                                                                                                                                                                                                         
		}                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                               
	});                                                                                                                                                                                                                                                           
});                                                                                                                                                                                                                                                            