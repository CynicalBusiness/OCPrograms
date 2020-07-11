{
    path = "/usr",
    repos = {
        ["CynicalBusiness/OCPrograms"] = {
            ["harvesters"] = {
                files = {
                    [":master/harvester/usr"] = "/lib/harvester",
                    [":master/harvester/bin"] = "/bin",
                    ["master/harvester/man/harvester.txt"] = "/man/harvester",
                    ["master/harvester/man/harvester-edit.txt"] = "/man/harvester-edit",
                    ["?master/harvester/etc/harvester.cfg.lua"] = "//etc/harvester.cfg",
                },
                name = "Harvester Controller",
                description = "Control system for managing redstone-controlled harvesters to run to specified quantities in an Applied Energistics ME system.",
                authors = "CynicalBusiness",
                note = "Has two command line utilities for both controlling harvesters and actually operating them. See 'man harvester' and 'man harvester-edit'."
            }
        }
    }
}
