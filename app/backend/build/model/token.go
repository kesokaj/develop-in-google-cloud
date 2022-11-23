package model

/*
func GetAPIToken(reqToken string) string {
	var tempToken = os.Getenv("TEMP_TOKEN")
	splitToken := strings.Split(reqToken, "Bearer")
	if len(splitToken) == 1 {
		reqToken = "No token provided"
	} else if len(splitToken) != 2 {
		reqToken = "Something error with the token"
	} else {
		reqToken = strings.TrimSpace(splitToken[1])
		if reqToken != tempToken {
			db := DbConnect()
			query := db.QueryRow("select token from tokens where token = '" + reqToken + "'").Scan(&reqToken)
			if query != nil {
				reqToken = "Invalid token"
			}
			defer db.Close()
		} else {
			if reqToken == tempToken {
				reqToken = tempToken
				log.Info("Using temporary token")
			} else {
				log.Error("Invalid token")
			}
		}
	}
	return reqToken
}*/
