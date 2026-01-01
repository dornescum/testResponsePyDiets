In Pandas:
import pandas as pd

df = pd.read_csv('logs/activity.csv')

# Most active users
df.groupby('user_name').size().sort_values(ascending=False)

# Requests by hour
df['hour'] = pd.to_datetime(df['timestamp']).dt.hour
df.groupby('hour').size().plot(kind='bar')

# Most accessed routes
df.groupby('path').size().sort_values(ascending=False).head(10)

# Error rate by route
df[df['status'] >= 400].groupby('path').size()
