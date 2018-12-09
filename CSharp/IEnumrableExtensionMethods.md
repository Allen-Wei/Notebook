
# ������չ����

	/// <summary>
	/// �����ݰ�ÿ�� countPerGroup �����з���
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="data">����</param>
	/// <param name="countPerGroup">ÿ������</param>
	/// <returns></returns>
	public static List<IEnumerable<T>> Group<T>(this IEnumerable<T> data, int countPerGroup)
	{
		List<IEnumerable<T>> groups = new List<IEnumerable<T>>();
		if (!data.Any()) return groups;

		var groupsCount = Math.Ceiling((double)data.Count() / countPerGroup);

		for (var index = 0; index < groupsCount; index++)
		{
			var group = data.Skip(index * countPerGroup).Take(countPerGroup);
			groups.Add(group);
		}
		return groups;
	}

	/// <summary>
	/// �����ݷָ�� groupsCount ��
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="data">����</param>
	/// <param name="groupsCount">�ָ�ɶ�����</param>
	/// <returns></returns>
	public static List<IEnumerable<T>> Split<T>(this IEnumerable<T> data, int groupsCount)
	{
		List<IEnumerable<T>> groups = new List<IEnumerable<T>>();
		if (!data.Any()) return groups.ToList();

		int countPerGrouop = (int)Math.Ceiling((double)data.Count() / groupsCount);

		for (int index = 0; index < groupsCount; index++)
		{
			var group = data.Skip(index * countPerGrouop).Take(countPerGrouop);
			groups.Add(group);
		}

		return groups;
	}

	/// <summary>
	/// �����ݷָ��ָ������(˳���޷�����һ��)
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="list"></param>
	/// <param name="parts"></param>
	/// <returns></returns>
	public static IEnumerable<IEnumerable<T>> Split1<T>(this IEnumerable<T> list, int parts)
	{
		int i = 0;
		var splits = from item in list
					 group item by i++ % parts into part
					 select part;
		return splits;
	}
