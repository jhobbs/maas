/* Copyright 2015 Canonical Ltd.  This software is licensed under the
 * GNU Affero General Public License version 3 (see the file LICENSE).
 *
 * MAAS Nodes List Controller
 */

angular.module('MAAS').controller('NodesListController', [
    '$scope', '$rootScope', '$timeout', 'NodesManager', 'DevicesManager',
    'RegionConnection', 'SearchService', function($scope, $rootScope, $timeout,
        NodesManager, DevicesManager, RegionConnection, SearchService) {

        // Set title and page.
        $rootScope.title = "Nodes";
        $rootScope.page = "nodes";

        // Set initial values.
        $scope.nodes = NodesManager.getItems();
        $scope.devices = DevicesManager.getItems();
        $scope.currentpage = "nodes";
        $scope.osinfo = null;

        $scope.tabs = {};
        // Nodes tab.
        $scope.tabs.nodes = {};
        $scope.tabs.nodes.pagetitle = "Nodes";
        $scope.tabs.nodes.currentpage = "nodes";
        $scope.tabs.nodes.manager = NodesManager;
        $scope.tabs.nodes.search = "";
        $scope.tabs.nodes.searchValid = true;
        $scope.tabs.nodes.selectedItems = NodesManager.getSelectedItems();
        $scope.tabs.nodes.filtered_items = [];
        $scope.tabs.nodes.predicate = 'fqdn';
        $scope.tabs.nodes.allViewableChecked = false;
        $scope.tabs.nodes.metadata = NodesManager.getMetadata();
        $scope.tabs.nodes.filters = SearchService.emptyFilter;
        $scope.tabs.nodes.column = 'fqdn';
        $scope.tabs.nodes.actionOption = null;
        $scope.tabs.nodes.takeActionOptions = [];
        $scope.tabs.nodes.actionErrorCount = 0;
        $scope.tabs.nodes.osSelection = {
            osystem: "",
            release: ""
        };

        // Device tab.
        $scope.tabs.devices = {};
        $scope.tabs.devices.pagetitle = "Devices";
        $scope.tabs.devices.currentpage = "devices";
        $scope.tabs.devices.manager = DevicesManager;
        $scope.tabs.devices.search = "";
        $scope.tabs.devices.searchValid = true;
        $scope.tabs.devices.selectedItems = DevicesManager.getSelectedItems();
        $scope.tabs.devices.filtered_items = [];
        $scope.tabs.devices.predicate = 'fqdn';
        $scope.tabs.devices.allViewableChecked = false;
        $scope.tabs.devices.metadata = DevicesManager.getMetadata();
        $scope.tabs.devices.filters = SearchService.emptyFilter;
        $scope.tabs.devices.column = 'fqdn';
        $scope.tabs.devices.actionOption = null;
        $scope.tabs.devices.takeActionOptions = [];
        $scope.tabs.devices.actionErrorCount = 0;

        // Options for add hardware dropdown.
        $scope.addHardwareOption = {
            name: "hardware",
            title: "Add Hardware"
        };
        $scope.addHardwareOptions = [
            $scope.addHardwareOption,
            {
                name: "chassis",
                title: "Add Chassis"
            }
        ];

        // This will hold the AddHardwareController once it is initialized.
        // The controller will set this variable as it's always a child or
        // this scope.
        $scope.addHardwareScope = null;

        // Called to update `allViewableChecked`.
        function updateAllViewableChecked(tab) {
            // Not checked when the filtered nodes are empty.
            if($scope.tabs[tab].filtered_items.length === 0) {
                $scope.tabs[tab].allViewableChecked = false;
                return;
            }

            // Loop through all filtered nodes and see if all are checked.
            var i;
            for(i = 0; i < $scope.tabs[tab].filtered_items.length; i++) {
                if(!$scope.tabs[tab].filtered_items[i].$selected) {
                    $scope.tabs[tab].allViewableChecked = false;
                    return;
                }
            }
            $scope.tabs[tab].allViewableChecked = true;
        }

        // Clear the action if required.
        function shouldClearAction(tab) {
            if($scope.tabs[tab].selectedItems.length === 0) {
                if($scope.tabs[tab].search === "in:selected") {
                    $scope.tabs[tab].search = "";
                }
                $scope.tabs[tab].actionOption = null;
                if(tab === "nodes") {
                    $scope.tabs[tab].osSelection.osystem = "";
                    $scope.tabs[tab].osSelection.release = "";
                }
            }
        }

        // Update the number of selected items which have an error based on the
        // current selected action.
        function updateActionErrorCount(tab) {
            var i;
            $scope.tabs[tab].actionErrorCount = 0;
            for(i = 0; i < $scope.tabs[tab].selectedItems.length; i++) {
                var supported = $scope.supportsAction(
                    $scope.tabs[tab].selectedItems[i], tab);
                if(!supported) {
                    $scope.tabs[tab].actionErrorCount += 1;
                }
            }
        }

        // Load the support operating systems and releases.
        var loadOSReleasesPromise;
        function loadOSReleases(reload) {
            var callAgain = function() {
                loadOSReleases(reload);
            };

            RegionConnection.callMethod("general.osinfo", {}).then(
                function(osinfo) {
                    $scope.osinfo = osinfo;
                    if(osinfo.osystems.length === 0) {
                        // No operating systems, so no clusters have imported
                        // images. Update every 3 seconds.
                        loadOSReleasesPromise = $timeout(callAgain, 3000);
                    } else if(reload) {
                        // Reload enabled, update every 10 seconds.
                        loadOSReleasesPromise = $timeout(callAgain, 10000);
                    }
                }, function(error) {
                    // Failed to load the osinfo, try again in 3 sconds.
                    console.log("Failed to load os info: " + error);
                    loadOSReleasesPromise = $timeout(callAgain, 3000);
                });
        }

        // Cancel the loading of operating systems and releases.
        function cancelLoadOSReleases() {
            if(angular.isObject(loadOSReleasesPromise)) {
                $timeout.cancel(loadOSReleasesPromise);
                loadOSReleasesPromise = null;
            }
        }

        // Toggles between the current tab.
        $scope.toggleTab = function(tab) {
            $rootScope.title = $scope.tabs[tab].pagetitle;
            $scope.currentpage = tab;
        };

        // Mark a node as selected or unselected.
        $scope.toggleChecked = function(node, tab) {
            if($scope.tabs[tab].manager.isSelected(node.system_id)) {
                $scope.tabs[tab].manager.unselectItem(node.system_id);
            } else {
                $scope.tabs[tab].manager.selectItem(node.system_id);
            }
            updateAllViewableChecked(tab);
            updateActionErrorCount(tab);
            shouldClearAction(tab);
        };

        // Select all viewable nodes or deselect all viewable nodes.
        $scope.toggleCheckAll = function(tab) {
            if($scope.tabs[tab].allViewableChecked) {
                angular.forEach(
                    $scope.tabs[tab].filtered_items, function(node) {
                        $scope.tabs[tab].manager.unselectItem(node.system_id);
                });
            } else {
                angular.forEach(
                    $scope.tabs[tab].filtered_items, function(node) {
                        $scope.tabs[tab].manager.selectItem(node.system_id);
                });
            }
            updateAllViewableChecked(tab);
            updateActionErrorCount(tab);
            shouldClearAction(tab);
        };

        // When the filtered nodes change update if all check buttons
        // should be checked or not.
        $scope.$watchCollection("tabs.nodes.filtered_items", function() {
            updateAllViewableChecked("nodes");
        });
        $scope.$watchCollection("tabs.devices.filtered_items", function() {
            updateAllViewableChecked("devices");
        });

        // Adds or removes a filter to the search.
        $scope.toggleFilter = function(type, value, tab) {
            $scope.tabs[tab].filters = SearchService.toggleFilter(
                $scope.tabs[tab].filters, type, value);
            $scope.tabs[tab].search = SearchService.filtersToString(
                $scope.tabs[tab].filters);
        };

        // Return True if the filter is active.
        $scope.isFilterActive = function(type, value, tab) {
            return SearchService.isFilterActive(
                $scope.tabs[tab].filters, type, value);
        };

        // Update the filters object when the search bar is updated.
        $scope.updateFilters = function(tab) {
            var filters = SearchService.getCurrentFilters(
                $scope.tabs[tab].search);
            if(filters === null) {
                $scope.tabs[tab].filters = SearchService.emptyFilter;
                $scope.tabs[tab].searchValid = false;
            } else {
                $scope.tabs[tab].filters = filters;
                $scope.tabs[tab].searchValid = true;
            }
        };

        // Return True if the node supports the action.
        $scope.supportsAction = function(node, tab) {
            if(!$scope.tabs[tab].actionOption) {
                return true;
            }
            return node.actions.indexOf(
                $scope.tabs[tab].actionOption.name) >= 0;
        };

        // Called when the action option gets changed.
        $scope.actionOptionSelected = function(tab) {
            updateActionErrorCount(tab);
            $scope.tabs[tab].search = "in:selected";

            var actionOption = $scope.tabs[tab].actionOption;
            if(angular.isObject(actionOption) &&
                actionOption.name === "deploy") {
                loadOSReleases(true);
            } else {
                cancelLoadOSReleases();
            }

            // Hide the add hardware section.
            if (tab === 'nodes') {
                if(angular.isObject($scope.addHardwareScope)) {
                    $scope.addHardwareScope.hide();
                }
            }
        };

        // Return True if there is an action error.
        $scope.isActionError = function(tab) {
            if(angular.isObject($scope.tabs[tab].actionOption) &&
                $scope.tabs[tab].actionOption.name === "deploy" &&
                $scope.osinfo.osystems.length === 0 &&
                $scope.tabs[tab].actionErrorCount === 0) {
                return true;
            }
            return $scope.tabs[tab].actionErrorCount !== 0;
        };

        // Return True if unable to deploy because of missing images.
        $scope.isDeployError = function(tab) {
            if($scope.tabs[tab].actionErrorCount !== 0) {
                return false;
            }
            if(angular.isObject($scope.tabs[tab].actionOption) &&
                $scope.tabs[tab].actionOption.name === "deploy" &&
                $scope.osinfo.osystems.length === 0) {
                return true;
            }
            return false;
        };

        // Called when the current action is cancelled.
        $scope.actionCancel = function(tab) {
            if($scope.tabs[tab].search === "in:selected") {
                $scope.tabs[tab].search = "";
            }
            $scope.tabs[tab].actionOption = null;
            cancelLoadOSReleases();
        };

        // Perform the action on all nodes.
        $scope.actionGo = function(tab) {
            var extra = {};

            // Set deploy parameters if a deploy action.
            if($scope.tabs[tab].actionOption.name === "deploy" &&
                angular.isString($scope.tabs[tab].osSelection.osystem) &&
                angular.isString($scope.tabs[tab].osSelection.release)) {

                // Set extra. UI side the release is structured os/release, but
                // when it is sent over the websocket only the "release" is
                // sent.
                extra.osystem = $scope.tabs[tab].osSelection.osystem;
                var release = $scope.tabs[tab].osSelection.release;
                release = release.split("/");
                release = release[release.length-1];
                extra.distro_series = release;
            }

            // Perform the action on all selected items.
            angular.forEach($scope.tabs[tab].selectedItems, function(node) {
                $scope.tabs[tab].manager.performAction(
                    node, $scope.tabs[tab].actionOption.name,
                    extra).then(function() {
                        $scope.tabs[tab].manager.unselectItem(node.system_id);
                        shouldClearAction(tab);
                    }, function(error) {
                        // Report error loading. This is simple handlng for
                        // now but this should show a nice error dialog or
                        // something.
                        console.log(error);
                    });
            });
        };

        // Called to show the add hardware view.
        $scope.showAddHardware = function() {
            $scope.addHardwareScope.show(
                $scope.addHardwareOption.name);
        };

        // Make sure connected to region then load all the nodes.
        RegionConnection.defaultConnect().then(function() {
            angular.forEach($scope.tabs, function(tab) {
                var manager = tab.manager;
                if(!manager.isLoaded()) {
                    // Load the initial nodes.
                    manager.loadItems().then(null, function(error) {
                        // Report error loading. This is simple handlng for now
                        // but this should show a nice error dialog or
                        // something.
                        console.log(error);
                    });
                }
                manager.enableAutoReload();
            });

            // Load all of the available actions.
            RegionConnection.callMethod("general.actions", {}).then(
                function(actions) {
                    angular.forEach($scope.tabs, function(tab) {
                        tab.takeActionOptions = actions;
                    });
                });

            // Initially load osinfo, but don't keep reloading.
            loadOSReleases(false);
        });
    }]);