/* Copyright 2015 Canonical Ltd.  This software is licensed under the
 * GNU Affero General Public License version 3 (see the file LICENSE).
 *
 * Unit tests for NodesListController.
 */

describe("NodesListController", function() {

    // Load the MAAS module.
    beforeEach(module("MAAS"));

    // Grab the needed angular pieces.
    var $controller, $rootScope, $timeout, $scope, $q;
    beforeEach(inject(function($injector) {
        $controller = $injector.get("$controller");
        $rootScope = $injector.get("$rootScope");
        $timeout = $injector.get("$timeout");
        $scope = $rootScope.$new();
        $q = $injector.get("$q");
    }));

    // Load the NodesManager, DevicesManager, RegionConnection,
    // SearchService and mock the websocket connection.
    var NodesManager, DevicesManager, RegionConnection, SearchService;
    var webSocket;
    beforeEach(inject(function($injector) {
        NodesManager = $injector.get("NodesManager");
        DevicesManager = $injector.get("DevicesManager");
        RegionConnection = $injector.get("RegionConnection");
        SearchService = $injector.get("SearchService");

        // Mock buildSocket so an actual connection is not made.
        webSocket = new MockWebSocket();
        spyOn(RegionConnection, "buildSocket").and.returnValue(webSocket);
    }));

    // Makes the NodesListController
    function makeController(defer) {
        var defaultConnect = spyOn(RegionConnection, "defaultConnect");
        if(angular.isObject(defer)) {
            defaultConnect.and.returnValue(defer.promise);
        } else {
            defaultConnect.and.returnValue($q.defer().promise);
        }

        // Start the connection so a valid websocket is created in the
        // RegionConnection.
        RegionConnection.connect("");

        return $controller("NodesListController", {
            $scope: $scope,
            $rootScope: $rootScope,
            $timeout: $timeout,
            NodesManager: NodesManager,
            DevicesManager: DevicesManager,
            RegionConnection: RegionConnection,
            SearchService: SearchService
        });
    }

    // Makes a fake node/device.
    function makeObject(tab) {
        if (tab === 'nodes') {
            var node = {
                system_id: makeName("system_id"),
                $selected: false
            };
            NodesManager._items.push(node);
            return node;
        }
        else if (tab === 'devices') {
            var device = {
                system_id: makeName("system_id"),
                $selected: false
            };
            DevicesManager._items.push(device);
            return device;
        }
        return null;
    }

    it("sets title and page on $rootScope", function() {
        var controller = makeController();
        expect($rootScope.title).toBe("Nodes");
        expect($rootScope.page).toBe("nodes");
    });

    it("sets initial values on $scope", function() {
        // tab-independant variables.
        var controller = makeController();
        expect($scope.nodes).toBe(NodesManager.getItems());
        expect($scope.devices).toBe(DevicesManager.getItems());
        expect($scope.osinfo).toBeNull();
        expect($scope.addHardwareOption).toEqual({
            name: "hardware",
            title: "Add Hardware"
        });
        expect($scope.addHardwareOptions).toEqual([
            {
                name: "hardware",
                title: "Add Hardware"
            },
            {
                name: "chassis",
                title: "Add Chassis"
            }
        ]);
        expect($scope.addHardwareScope).toBeNull();
    });

    it("loads initial osinfo", function() {
        spyOn(NodesManager, "isLoaded").and.returnValue(true);
        spyOn(NodesManager, "enableAutoReload");
        spyOn(DevicesManager, "isLoaded").and.returnValue(true);
        spyOn(DevicesManager, "enableAutoReload");

        // Mock the RegionConnection.callMethod to catch all calls.
        var defers = [
            $q.defer(),
            $q.defer()
            ];
        var i = 0;
        spyOn(RegionConnection, "callMethod").and.callFake(
            function(method) {
                return defers[i++].promise;
            });

        var osinfo = {
            "osystems": [makeName("os")]
        };
        var defer = $q.defer();
        var controller = makeController(defer);

        // Resolve defaultConnect to start the calls.
        defer.resolve();
        $scope.$digest();

        // Resolve the general.actions call.
        defers[0].resolve([]);
        $scope.$digest();

        // Resolve the general.osinfo call to get the osinfo.
        defers[1].resolve(osinfo);
        $scope.$digest();
        expect($scope.osinfo).toBe(osinfo);
    });

    it("doesnt reload osinfo", function() {
        spyOn(NodesManager, "isLoaded").and.returnValue(true);
        spyOn(NodesManager, "enableAutoReload");
        spyOn(DevicesManager, "isLoaded").and.returnValue(true);
        spyOn(DevicesManager, "enableAutoReload");

        // Mock the RegionConnection.callMethod to catch all calls.
        var defers = [
            $q.defer(),
            $q.defer(),
            $q.defer()
            ];
        var i = 0;
        spyOn(RegionConnection, "callMethod").and.callFake(
            function(method) {
                return defers[i++].promise;
            });

        var osinfo = {
            "osystems": [makeName("os")]
        };
        var defer = $q.defer();
        var controller = makeController(defer);

        // Resolve defaultConnect to start the calls.
        defer.resolve();
        $scope.$digest();

        // Resolve the general.actions call.
        defers[0].resolve([]);
        $scope.$digest();

        // Resolve the general.osinfo call to get the osinfo.
        defers[1].resolve(osinfo);
        $scope.$digest();

        // Skip 10 seconds, a second osinfo call would occur if reload=true.
        // It should not occur, so call count should only be 2.
        $timeout.flush(10000);
        expect(RegionConnection.callMethod.calls.count()).toBe(2);
    });

    it("reload osinfo after 3 secs on error", function() {
        spyOn(NodesManager, "isLoaded").and.returnValue(true);
        spyOn(NodesManager, "enableAutoReload");
        spyOn(DevicesManager, "isLoaded").and.returnValue(true);
        spyOn(DevicesManager, "enableAutoReload");

        // Mock the RegionConnection.callMethod to catch all calls.
        var defers = [
            $q.defer(),
            $q.defer(),
            $q.defer()
            ];
        var i = 0;
        spyOn(RegionConnection, "callMethod").and.callFake(
            function(method) {
                return defers[i++].promise;
            });

        var osinfo = {
            "osystems": [makeName("os")]
        };
        var defer = $q.defer();
        var controller = makeController(defer);

        // Resolve defaultConnect to start the calls.
        defer.resolve();
        $scope.$digest();

        // Resolve the general.actions call.
        defers[0].resolve([]);
        $scope.$digest();

        // Reject the general.osinfo call to get it to be called again
        // in 3 seconds.
        spyOn(console, "log");
        defers[1].reject("error");
        $scope.$digest();

        // Skip 3 seconds, a second osinfo should occur.
        $timeout.flush(3000);
        defers[2].resolve(osinfo);
        $scope.$digest();
        expect($scope.osinfo).toBe(osinfo);
    });

    describe("toggleTab", function() {

        it("sets $rootScope.title", function() {
            var controller = makeController();
            $scope.toggleTab('devices');
            expect($rootScope.title).toBe($scope.tabs.devices.pagetitle);
            $scope.toggleTab('nodes');
            expect($rootScope.title).toBe($scope.tabs.nodes.pagetitle);
        });

        it("sets currentpage", function() {
            var controller = makeController();
            $scope.toggleTab('devices');
            expect($scope.currentpage).toBe('devices');
            $scope.toggleTab('nodes');
            expect($scope.currentpage).toBe('nodes');
        });
    });

    angular.forEach(["nodes", "devices"], function(tab) {

        describe("tab(" + tab + ")", function() {

            var manager;
            beforeEach(function() {
                if(tab === "nodes") {
                    manager = NodesManager;
                } else if(tab === "devices") {
                    manager = DevicesManager;
                } else {
                    throw new Error("Unknown manager for tab: " + tab);
                }
            });

            it("sets initial values on $scope", function() {
                var controller = makeController();
                var tabScope = $scope.tabs[tab];
                expect(tabScope.search).toBe("");
                expect(tabScope.searchValid).toBe(true);
                expect(tabScope.filtered_items).toEqual([]);
                expect(tabScope.predicate).toBe("fqdn");
                expect(tabScope.allViewableChecked).toBe(false);
                expect(tabScope.selectedItems).toBe(
                    tabScope.manager.getSelectedItems());
                expect(tabScope.metadata).toBe(tabScope.manager.getMetadata());
                expect(tabScope.filters).toBe(SearchService.emptyFilter);
                expect(tabScope.column).toBe("fqdn");
                expect(tabScope.actionOption).toBeNull();
                expect(tabScope.takeActionOptions).toEqual([]);
                expect(tabScope.actionErrorCount).toBe(0);

                // Only the nodes tab uses the osSelection field.
                if(tab === "nodes") {
                    expect(tabScope.osSelection).toEqual({
                        osystem: "",
                        release: ""
                    });
                }
            });

            it("calls tab manager loadItems if not loaded",
                function(done) {
                spyOn(manager, "loadItems").and.callFake(function() {
                    done();
                    return $q.defer().promise;
                });
                var defer = $q.defer();
                var controller = makeController(defer);
                defer.resolve();
                $scope.$digest();
            });

            it("doesnt call loadItems if loaded", function() {
                spyOn(manager, "isLoaded").and.returnValue("true");
                spyOn(manager, "loadItems").and.returnValue(
                    $q.defer().promise);
                var defer = $q.defer();
                var controller = makeController(defer);
                defer.resolve();
                $scope.$digest();
                expect(manager.loadItems).not.toHaveBeenCalled();
            });

        });

    });

    angular.forEach(["nodes", "devices"], function(tab) {

        describe("tab(" + tab + ")", function() {

            describe("toggleChecked", function() {

                var controller, object, tabObj;
                beforeEach(function() {
                    controller = makeController();
                    object = makeObject(tab);
                    tabObj = $scope.tabs[tab];
                    $scope.tabs.nodes.filtered_items = $scope.nodes;
                    $scope.tabs.devices.filtered_items = $scope.devices;
                });

                it("selects object", function() {
                    $scope.toggleChecked(object, tab);
                    expect(object.$selected).toBe(true);
                });

                it("deselects object", function() {
                    tabObj.manager.selectItem(object.system_id);
                    $scope.toggleChecked(object, tab);
                    expect(object.$selected).toBe(false);
                });

                it("sets allViewableChecked to true when all objects selected",
                    function() {
                        $scope.toggleChecked(object, tab);
                        expect(tabObj.allViewableChecked).toBe(true);
                });

                it(
                    "sets allViewableChecked to false when not all objects " +
                    "selected",
                    function() {
                        var object2 = makeObject(tab);
                        $scope.toggleChecked(object, tab);
                        expect(tabObj.allViewableChecked).toBe(false);
                });

                it("sets allViewableChecked to false when selected and " +
                    "deselected",
                    function() {
                        $scope.toggleChecked(object, tab);
                        $scope.toggleChecked(object, tab);
                        expect(tabObj.allViewableChecked).toBe(false);
                });

                it("resets search when in:selected and none selected",
                    function() {
                    tabObj.search = "in:selected";
                    $scope.toggleChecked(object, tab);
                    $scope.toggleChecked(object, tab);
                    expect(tabObj.search).toBe("");
                });

                it("ignores search when not in:selected and none selected",
                    function() {
                    tabObj.search = "other";
                    $scope.toggleChecked(object, tab);
                    $scope.toggleChecked(object, tab);
                    expect(tabObj.search).toBe("other");
                });

                it("updates actionErrorCount", function() {
                    object.actions = [];
                    tabObj.actionOption = {
                        "name": "deploy"
                    };
                    $scope.toggleChecked(object, tab);
                    expect(tabObj.actionErrorCount).toBe(1);
                });

                it("clears action option when none selected", function() {
                    object.actions = [];
                    tabObj.actionOption = {};
                    $scope.toggleChecked(object, tab);
                    $scope.toggleChecked(object, tab);
                    expect(tabObj.actionOption).toBeNull();
                });
            });

            describe("toggleCheckAll", function() {

                var controller, object1, object2, tabObj;
                beforeEach(function() {
                    controller = makeController();
                    object1 = makeObject(tab);
                    object2 = makeObject(tab);
                    tabObj = $scope.tabs[tab];
                    $scope.tabs.nodes.filtered_items = $scope.nodes;
                    $scope.tabs.devices.filtered_items = $scope.devices;
                });

                it("selects all objects", function() {
                    $scope.toggleCheckAll(tab);
                    expect(object1.$selected).toBe(true);
                    expect(object2.$selected).toBe(true);
                });

                it("deselects all objects", function() {
                    $scope.toggleCheckAll(tab);
                    $scope.toggleCheckAll(tab);
                    expect(object1.$selected).toBe(false);
                    expect(object2.$selected).toBe(false);
                });

                it("resets search when in:selected and none selected",
                    function() {
                    tabObj.search = "in:selected";
                    $scope.toggleCheckAll(tab);
                    $scope.toggleCheckAll(tab);
                    expect(tabObj.search).toBe("");
                });

                it("ignores search when not in:selected and none selected",
                    function() {
                    tabObj.search = "other";
                    $scope.toggleCheckAll(tab);
                    $scope.toggleCheckAll(tab);
                    expect(tabObj.search).toBe("other");
                });

                it("updates actionErrorCount", function() {
                    object1.actions = [];
                    object2.actions = [];
                    tabObj.actionOption = {
                        "name": "deploy"
                    };
                    $scope.toggleCheckAll(tab);
                    expect(tabObj.actionErrorCount).toBe(2);
                });

                it("clears action option when none selected", function() {
                    $scope.actionOption = {};
                    $scope.toggleCheckAll(tab);
                    $scope.toggleCheckAll(tab);
                    expect(tabObj.actionOption).toBeNull();
                });
            });

            describe("toggleFilter", function() {

                it("calls SearchService.toggleFilter", function() {
                    var controller = makeController();
                    spyOn(SearchService, "toggleFilter").and.returnValue(
                        SearchService.emptyFilter);
                    $scope.toggleFilter("hostname", "test", tab);
                    expect(SearchService.toggleFilter).toHaveBeenCalled();
                });

                it("sets $scope.filters", function() {
                    var controller = makeController();
                    var filters = { _: [], other: [] };
                    spyOn(SearchService, "toggleFilter").and.returnValue(
                        filters);
                    $scope.toggleFilter("hostname", "test", tab);
                    expect($scope.tabs[tab].filters).toBe(filters);
                });

                it("calls SearchService.filtersToString", function() {
                    var controller = makeController();
                    spyOn(SearchService, "filtersToString").and.returnValue(
                        "");
                    $scope.toggleFilter("hostname", "test", tab);
                    expect(SearchService.filtersToString).toHaveBeenCalled();
                });

                it("sets $scope.search", function() {
                    var controller = makeController();
                    $scope.toggleFilter("hostname", "test", tab);
                    expect($scope.tabs[tab].search).toBe("hostname:(test)");
                });
            });

            describe("isFilterActive", function() {

                it("returns true when active", function() {
                    var controller = makeController();
                    $scope.toggleFilter("hostname", "test", tab);
                    expect(
                        $scope.isFilterActive(
                            "hostname", "test", tab)).toBe(true);
                });

                it("returns false when inactive", function() {
                    var controller = makeController();
                    $scope.toggleFilter("hostname", "test2", tab);
                    expect(
                        $scope.isFilterActive(
                            "hostname", "test", tab)).toBe(false);
                });
            });

            describe("updateFilters", function() {

                it("updates filters and sets searchValid to true", function() {
                    var controller = makeController();
                    $scope.tabs[tab].search = "test hostname:name";
                    $scope.updateFilters(tab);
                    expect($scope.tabs[tab].filters).toEqual({
                        _: ["test"],
                        hostname: ["name"]
                    });
                    expect($scope.tabs[tab].searchValid).toBe(true);
                });

                it("updates sets filters empty and sets searchValid to false",
                    function() {
                        var controller = makeController();
                        $scope.tabs[tab].search = "test hostname:(name";
                        $scope.updateFilters(tab);
                        expect(
                            $scope.tabs[tab].filters).toBe(
                                SearchService.emptyFilter);
                        expect($scope.tabs[tab].searchValid).toBe(false);
                    });
            });

            describe("supportsAction", function() {

                it("returns true if actionOption is null", function() {
                    var controller = makeController();
                    var object = makeObject(tab);
                    object.actions = ["start", "stop"];
                    expect($scope.supportsAction(object, tab)).toBe(true);
                });

                it("returns true if actionOption in object.actions",
                    function() {
                    var controller = makeController();
                    var object = makeObject(tab);
                    object.actions = ["start", "stop"];
                    $scope.tabs.nodes.actionOption = { name: "start" };
                    expect($scope.supportsAction(object, tab)).toBe(true);
                });

                it("returns false if actionOption not in object.actions",
                    function() {
                    var controller = makeController();
                    var object = makeObject(tab);
                    object.actions = ["start", "stop"];
                    $scope.tabs[tab].actionOption = { name: "deploy" };
                    expect($scope.supportsAction(object, tab)).toBe(false);
                });
            });

        });

    });

    // No support for devices actions yet but the testing code is already
    // refactored to support it.
    angular.forEach(["nodes"], function(tab) {

        describe("tab(" + tab + ")", function() {

            describe("actionOptionSelected", function() {

                it("sets actionErrorCount to zero", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionErrorCount = 1;
                    $scope.actionOptionSelected(tab);
                    expect($scope.tabs[tab].actionErrorCount).toBe(0);
                });

                it("sets actionErrorCount to 1 when selected object doesn't " +
                    "support action",
                    function() {
                        var controller = makeController();
                        var object = makeObject(tab);
                        object.actions = ['start', 'stop'];
                        $scope.tabs[tab].actionOption = { name: 'deploy' };
                        $scope.tabs[tab].selectedItems = [object];
                        $scope.actionOptionSelected(tab);
                        expect($scope.tabs[tab].actionErrorCount).toBe(1);
                    });

                it("sets search to in:selected", function() {
                    var controller = makeController();
                    $scope.actionOptionSelected(tab);
                    expect($scope.tabs[tab].search).toBe("in:selected");
                });

                it("action deploy reloads osinfo", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = {
                        "name": "deploy"
                    };

                    var osinfo = {
                        osystems: [makeName("os")]
                    };

                    var loadDefer = $q.defer();
                    spyOn(RegionConnection, "callMethod").and.returnValue(
                        loadDefer.promise);

                    $scope.actionOptionSelected(tab);
                    loadDefer.resolve(osinfo);
                    $scope.$digest();
                    expect($scope.osinfo).toBe(osinfo);
                });

                it("action deploy reloads osinfo every 10 secs", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = {
                        "name": "deploy"
                    };

                    var osinfo1 = {
                        osystems: [makeName("os")]
                    };
                    var osinfo2 = {
                        osystems: [makeName("os")]
                    };

                    var defers = [
                        $q.defer(),
                        $q.defer()
                        ];
                    var i = 0;
                    spyOn(RegionConnection, "callMethod").and.callFake(
                        function(method) {
                            return defers[i++].promise;
                        });

                    $scope.actionOptionSelected(tab);

                    // First call.
                    defers[0].resolve(osinfo1);
                    $scope.$digest();
                    expect($scope.osinfo).toBe(osinfo1);

                    // Second call 10 seconds later.
                    $timeout.flush(10000);
                    defers[1].resolve(osinfo2);
                    $scope.$digest();
                    expect($scope.osinfo).toBe(osinfo2);
                });

                it("changing away from deploy stops osinfo reloads",
                    function() {
                        var controller = makeController();
                        $scope.tabs[tab].actionOption = {
                            "name": "deploy"
                        };

                        var osinfo1 = {
                            osystems: [makeName("os")]
                        };
                        var osinfo2 = {
                            osystems: [makeName("os")]
                        };

                        var defers = [
                            $q.defer(),
                            $q.defer()
                            ];
                        var i = 0;
                        spyOn(RegionConnection, "callMethod").and.callFake(
                            function(method) {
                                return defers[i++].promise;
                            });

                        $scope.actionOptionSelected(tab);

                        // First call.
                        defers[0].resolve(osinfo1);
                        $scope.$digest();
                        expect($scope.osinfo).toBe(osinfo1);

                        // Change action away from deploy, which should stop
                        // all calls.
                        $scope.tabs[tab].actionOption = {
                            "name": "acquire"
                        };
                        $scope.actionOptionSelected(tab);

                        // Second call would have occured 10 seconds later.
                        $timeout.flush(10000);
                        defers[1].resolve(osinfo2);
                        $scope.$digest();

                        // Should have not changed as the second call never
                        // happened.
                        expect($scope.osinfo).toBe(osinfo1);
                    });

                it("calls hide on addHardwareScope", function() {
                    if (tab === 'nodes') {
                        var controller = makeController();
                        $scope.addHardwareScope = {
                            hide: jasmine.createSpy("hide")
                        };
                        $scope.actionOptionSelected(tab);
                        expect(
                            $scope.addHardwareScope.hide).toHaveBeenCalled();
                    }
                });

            });

            describe("isActionError", function() {

                it("returns true if actionErrorCount > 0", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionErrorCount = 2;
                    expect($scope.isActionError(tab)).toBe(true);
                });

                it("returns false if actionErrorCount === 0", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionErrorCount = 0;
                    expect($scope.isActionError(tab)).toBe(false);
                });

                it("returns true if deploy action missing osinfo", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = {
                        name: "deploy"
                    };
                    $scope.tabs[tab].actionErrorCount = 0;
                    $scope.osinfo = {
                        osystems: []
                    };
                    expect($scope.isActionError(tab)).toBe(true);
                });

                it("returns false if deploy action not missing osinfo",
                    function() {
                        var controller = makeController();
                        $scope.tabs[tab].actionOption = {
                            name: "deploy"
                        };
                        $scope.tabs[tab].actionErrorCount = 0;
                        $scope.osinfo = {
                            osystems: [makeName("os")]
                        };
                        expect($scope.isActionError(tab)).toBe(false);
                    });
            });

            describe("isDeployError", function() {

                it("returns false if actionErrorCount > 0", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionErrorCount = 2;
                    expect($scope.isDeployError(tab)).toBe(false);
                });

                it("returns true if deploy action missing osinfo", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = {
                        name: "deploy"
                    };
                    $scope.tabs[tab].actionErrorCount = 0;
                    $scope.osinfo = {
                        osystems: []
                    };
                    expect($scope.isDeployError(tab)).toBe(true);
                });

                it("returns false if deploy action not missing osinfo",
                    function() {
                        var controller = makeController();
                        $scope.tabs[tab].actionOption = {
                            name: "deploy"
                        };
                        $scope.tabs[tab].actionErrorCount = 0;
                        $scope.osinfo = {
                            osystems: [makeName("os")]
                        };
                        expect($scope.isDeployError(tab)).toBe(false);
                    });
            });

            describe("actionCancel", function() {

                it("clears search if in:selected", function() {
                    var controller = makeController();
                    $scope.tabs[tab].search = "in:selected";
                    $scope.actionCancel(tab);
                    expect($scope.tabs[tab].search).toBe("");
                });

                it("clears search if in:selected (device)", function() {
                    var controller = makeController();
                    $scope.tabs.devices.search = "in:selected";
                    $scope.actionCancel('devices');
                    expect($scope.tabs.devices.search).toBe("");
                });

                it("doesnt clear search if not in:selected", function() {
                    var controller = makeController();
                    $scope.tabs[tab].search = "other";
                    $scope.actionCancel(tab);
                    expect($scope.tabs[tab].search).toBe("other");
                });

                it("sets actionOption to null", function() {
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = {};
                    $scope.actionCancel(tab);
                    expect($scope.tabs[tab].actionOption).toBeNull();
                });
            });

            describe("actionGo", function() {

                it("calls performAction for selected object", function() {
                    spyOn(NodesManager, "performAction").and.returnValue(
                        $q.defer().promise);
                    var controller = makeController();
                    var object = makeObject(tab);
                    $scope.tabs[tab].actionOption = { name: "start" };
                    $scope.tabs[tab].selectedItems = [object];
                    $scope.actionGo(tab);
                    expect(NodesManager.performAction).toHaveBeenCalledWith(
                        object, "start", {});
                });

                it("calls performAction with osystem and distro_series",
                    function() {
                        spyOn(NodesManager, "performAction").and.returnValue(
                            $q.defer().promise);
                        var controller = makeController();
                        var object = makeObject(tab);
                        $scope.tabs[tab].actionOption = { name: "deploy" };
                        $scope.tabs[tab].selectedItems = [object];
                        $scope.tabs[tab].osSelection = {
                            osystem: "ubuntu",
                            release: "ubuntu/trusty"
                        };
                        $scope.actionGo(tab);
                        expect(NodesManager.performAction).toHaveBeenCalledWith(
                            object, "deploy", {
                                osystem: "ubuntu",
                                distro_series: "trusty"
                            });
                });

                it("calls unselectItem after complete", function() {
                    var defer = $q.defer();
                    spyOn(NodesManager, "performAction").and.returnValue(
                        defer.promise);
                    spyOn(NodesManager, "unselectItem");
                    var controller = makeController();
                    var object = makeObject(tab);
                    $scope.tabs[tab].actionOption = { name: "start" };
                    $scope.tabs[tab].selectedItems = [object];
                    $scope.actionGo(tab);
                    defer.resolve();
                    $scope.$digest();
                    expect(NodesManager.unselectItem).toHaveBeenCalled();
                });

                it("calls unselectItem after complete", function() {
                    var defer = $q.defer();
                    spyOn(NodesManager, "performAction").and.returnValue(
                        defer.promise);
                    spyOn(NodesManager, "unselectItem");
                    var controller = makeController();
                    var object = makeObject(tab);
                    $scope.tabs[tab].actionOption = { name: "start" };
                    $scope.tabs[tab].selectedItems = [object];
                    $scope.actionGo(tab);
                    defer.resolve();
                    $scope.$digest();
                    expect(NodesManager.unselectItem).toHaveBeenCalled();
                });

                it("resets search when in:selected after complete",
                    function() {
                    var defer = $q.defer();
                    spyOn(NodesManager, "performAction").and.returnValue(
                        defer.promise);
                    var object = makeObject(tab);
                    NodesManager._items = [object];
                    NodesManager._selectedItems = [object];
                    var controller = makeController();
                    $scope.tabs[tab].search = "in:selected";
                    $scope.tabs[tab].actionOption = { name: "start" };
                    $scope.actionGo(tab);
                    defer.resolve();
                    $scope.$digest();
                    expect($scope.tabs[tab].search).toBe("");
                });

                it("ignores search when not in:selected after complete",
                    function() {
                    var defer = $q.defer();
                    spyOn(NodesManager, "performAction").and.returnValue(
                        defer.promise);
                    var object = makeObject(tab);
                    NodesManager._items = [object];
                    NodesManager._selectedItems = [object];
                    var controller = makeController();
                    $scope.tabs[tab].search = "other";
                    $scope.tabs[tab].actionOption = { name: "start" };
                    $scope.actionGo(tab);
                    defer.resolve();
                    $scope.$digest();
                    expect($scope.tabs[tab].search).toBe("other");
                });

                it("clears action option when complete", function() {
                    var defer = $q.defer();
                    spyOn(NodesManager, "performAction").and.returnValue(
                        defer.promise);
                    var object = makeObject(tab);
                    NodesManager._items = [object];
                    NodesManager._selectedItems = [object];
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = { name: "start" };
                    $scope.actionGo(tab);
                    defer.resolve();
                    $scope.$digest();
                    expect($scope.tabs[tab].actionOption).toBeNull();
                });

                it("clears selected os and release when complete", function() {
                    var defer = $q.defer();
                    spyOn(NodesManager, "performAction").and.returnValue(
                        defer.promise);
                    var object = makeObject(tab);
                    NodesManager._items = [object];
                    NodesManager._selectedItems = [object];
                    var controller = makeController();
                    $scope.tabs[tab].actionOption = { name: "deploy" };
                    $scope.tabs[tab].osSelection = {
                        osystem: "ubuntu",
                        release: "ubuntu/trusty"
                    };
                    $scope.actionGo(tab);
                    defer.resolve();
                    $scope.$digest();
                    expect($scope.tabs[tab].osSelection.osystem).toBe("");
                    expect($scope.tabs[tab].osSelection.release).toBe("");
                });

                it("calls show in addHardwareScope", function() {
                    var controller = makeController();
                    $scope.addHardwareScope = {
                        show: jasmine.createSpy("show")
                    };
                    $scope.addHardwareOption = {
                        name: "hardware"
                    };
                    $scope.showAddHardware();
                    expect(
                        $scope.addHardwareScope.show).toHaveBeenCalledWith(
                            "hardware");
                });
            });

        });
    });
});