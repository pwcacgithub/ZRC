sap.ui.define([                                                                                                                                                                                                                                                
	"sap/ui/core/mvc/Controller",                                                                                                                                                                                                                                 
	"sap/m/Dialog",                                                                                                                                                                                                                                               
	"sap/m/Button",                                                                                                                                                                                                                                               
	"sap/m/Text"                                                                                                                                                                                                                                                  
], function(Controller, Dialog, Button, Text) {                                                                                                                                                                                                                
	"use strict";                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                               
	return Controller.extend("UpdateCheque.controller.DocumentDisplay", {                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
		/**                                                                                                                                                                                                                                                          
		 * Called when a controller is instantiated and its View controls (if available) are already created.                                                                                                                                                        
		 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.                                                                                                                                       
		 * @memberOf UpdateCheque.view.DocumentDisplay                                                                                                                                                                                                               
		 */                                                                                                                                                                                                                                                          
			onInit: function() {                                                                                                                                                                                                                                        
				var oMessageManager = sap.ui.getCore().getMessageManager();                                                                                                                                                                                                
				var oMessageProcessor = oMessageManager.getMessageModel();                                                                                                                                                                                                 
				oMessageManager.registerMessageProcessor(oMessageProcessor);                                                                                                                                                                                               
	                                                                                                                                                                                                                                                              
				this.getView().setModel(sap.ui.getCore().getMessageManager().getMessageModel(), "messages");                                                                                                                                                               
			},                                                                                                                                                                                                                                                          
			                                                                                                                                                                                                                                                            
			handleDocUpdate: function() {                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                               
			var oTable = this.getView().byId("idDocumentTable");                                                                                                                                                                                                        
			var aContexts = oTable.getSelectedContexts();                                                                                                                                                                                                               
			var aTableData = [];                                                                                                                                                                                                                                        
			                                                                                                                                                                                                                                                            
			if (aContexts.length <1) {                                                                                                                                                                                                                                  
				                                                                                                                                                                                                                                                           
				sap.m.MessageToast.show("Please Select a record to Update");                                                                                                                                                                                               
				return;                                                                                                                                                                                                                                                    
			}                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                               
			$.each(aContexts, function(index, oContext) {                                                                                                                                                                                                               
				var oData = oContext.getObject();                                                                                                                                                                                                                          
				aTableData.push(oData);                                                                                                                                                                                                                                    
			});                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
			var oPostingModel = this.getView().getModel();                                                                                                                                                                                                              
			var oPostingData = {                                                                                                                                                                                                                                        
				"count": "1",                                                                                                                                                                                                                                              
				// E2T system                                                                                                                                                                                                                                              
				"fb02_itemSet": aTableData                                                                                                                                                                                                                                 
			};                                                                                                                                                                                                                                                          
			var oController = this;                                                                                                                                                                                                                                     
			                                                                                                                                                                                                                                                            
			sap.ui.getCore().getMessageManager().removeAllMessages();                                                                                                                                                                                                   
			                                                                                                                                                                                                                                                            
			oPostingModel.create("/fb02_headSet", oPostingData, {                                                                                                                                                                                                       
				success: function(oData, oResponse) {                                                                                                                                                                                                                      
					sap.m.MessageToast.show("Click on the Message Icon at the bottom to see the log");                                                                                                                                                                        
				},                                                                                                                                                                                                                                                         
				error: function(oResponse) {                                                                                                                                                                                                                               
					sap.m.MessageToast.show("Click on the Message Icon at the bottom to see the log");                                                                                                                                                                        
				}                                                                                                                                                                                                                                                          
			});                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
		},                                                                                                                                                                                                                                                           
		                                                                                                                                                                                                                                                             
		handleMessagesPress: function(oEvent) {                                                                                                                                                                                                                      
			// Get a reference to the button that raised this event                                                                                                                                                                                                     
			var oSource = oEvent.getSource();                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                               
			// Create an instance of the MessagePopover control. Store a reference to the created popover so that we create it only once.                                                                                                                               
			if (!this._oMessagePopover) {                                                                                                                                                                                                                               
				// Instantiate                                                                                                                                                                                                                                             
				this._oMessagePopover = sap.ui.xmlfragment("UpdateCheque.fragments.message");                                                                                                                                                                              
				this.getView().addDependent(this._oMessagePopover);                                                                                                                                                                                                        
			}                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                               
			// Open the MessagePopover                                                                                                                                                                                                                                  
			this._oMessagePopover.openBy(oSource);                                                                                                                                                                                                                      
		},                                                                                                                                                                                                                                                           
		                                                                                                                                                                                                                                                             
		clearMessages: function(oEvent) {                                                                                                                                                                                                                            
			                                                                                                                                                                                                                                                            
			var dialog = new Dialog({                                                                                                                                                                                                                                   
				title: 'Confirm',                                                                                                                                                                                                                                          
				type: 'Message',                                                                                                                                                                                                                                           
				content: new Text({ text: 'Do you want to clear the messages?' }),                                                                                                                                                                                         
				beginButton: new Button({                                                                                                                                                                                                                                  
					text: 'Yes',                                                                                                                                                                                                                                              
					press: function () {                                                                                                                                                                                                                                      
						// MessageToast.show('Submit pressed!');                                                                                                                                                                                                                 
						sap.ui.getCore().getMessageManager().removeAllMessages();                                                                                                                                                                                                
						dialog.close();                                                                                                                                                                                                                                          
					}                                                                                                                                                                                                                                                         
				}),                                                                                                                                                                                                                                                        
				endButton: new Button({                                                                                                                                                                                                                                    
					text: 'Cancel',                                                                                                                                                                                                                                           
					press: function () {                                                                                                                                                                                                                                      
						dialog.close();                                                                                                                                                                                                                                          
					}                                                                                                                                                                                                                                                         
				}),                                                                                                                                                                                                                                                        
				afterClose: function() {                                                                                                                                                                                                                                   
					dialog.destroy();                                                                                                                                                                                                                                         
				}                                                                                                                                                                                                                                                          
			});                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
			dialog.open();                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                               
		}                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                               
		/**                                                                                                                                                                                                                                                          
		 * Similar to onAfterRendering, but this hook is invoked before the controller's View is re-rendered                                                                                                                                                         
		 * (NOT before the first rendering! onInit() is used for that one!).                                                                                                                                                                                         
		 * @memberOf UpdateCheque.view.DocumentDisplay                                                                                                                                                                                                               
		 */                                                                                                                                                                                                                                                          
		//	onBeforeRendering: function() {                                                                                                                                                                                                                           
		//                                                                                                                                                                                                                                                           
		//	},                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                               
		/**                                                                                                                                                                                                                                                          
		 * Called when the View has been rendered (so its HTML is part of the document). Post-rendering manipulations of the HTML could be done here.                                                                                                                
		 * This hook is the same one that SAPUI5 controls get after being rendered.                                                                                                                                                                                  
		 * @memberOf UpdateCheque.view.DocumentDisplay                                                                                                                                                                                                               
		 */                                                                                                                                                                                                                                                          
		//	onAfterRendering: function() {                                                                                                                                                                                                                            
		//                                                                                                                                                                                                                                                           
		//	},                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                               
		/**                                                                                                                                                                                                                                                          
		 * Called when the Controller is destroyed. Use this one to free resources and finalize activities.                                                                                                                                                          
		 * @memberOf UpdateCheque.view.DocumentDisplay                                                                                                                                                                                                               
		 */                                                                                                                                                                                                                                                          
		//	onExit: function() {                                                                                                                                                                                                                                      
		//                                                                                                                                                                                                                                                           
		//	}                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
	});                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                               
});                                                                                                                                                                                                                                                            