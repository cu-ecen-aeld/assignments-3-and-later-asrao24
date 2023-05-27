#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    // Check if both arguments are provided
    if (argc < 3) {
        syslog(LOG_USER | LOG_ERR, "Insufficient arguments!");
        return 1;
    }

    // Retrieve the file path and string from the command-line arguments
    char *writefile = argv[1];
    char *writestr = argv[2];

    // Open the file in write mode
    FILE *file = fopen(writefile, "w");
    if (file == NULL) {
        syslog(LOG_USER | LOG_ERR, "Unable to create the file!");
        return 1;
    }

    // Log the message before writing to the file
    syslog(LOG_USER | LOG_DEBUG, "Writing %s to %s", writestr, writefile);

    // Write the string to the file
    fprintf(file, "%s", writestr);

    // Close the file
    fclose(file);

    return 0;
}

